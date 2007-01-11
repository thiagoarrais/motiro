#  Motiro - A project tracking tool
#  Copyright (C) 2006-2007  Thiago Arrais
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require 'rexml/rexml'

require 'models/headline'
require 'core/reporter'
require 'reporters/darcs_connection'

class DarcsReporter < MotiroReporter

  def initialize(conn=DarcsConnection.new)
    @connection = conn
  end
  
  def latest_headlines
    @connection.pull
    parse_headlines(@connection.changes)
  end
  
  def headlines
    parse_headlines(@connection.changes(:all))
  end
  
  def headline(rid)
    parse_headlines(@connection.changes(rid)).first
  end
  
  def author_from_darcs_id(id)
    md = id.match(/@/)
    return md.pre_match if md
  end
  
  def time_from_darcs_date(date)
    md = date.match(/(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/)
    nums = md[1..6].collect do |s| s.to_i end
    Time.utc(nums[0], nums[1], nums[2], nums[3], nums[4], nums[5], nums[6])
  end
  
private

  def parse_headlines(xml_input)
    patches = REXML::Document.new(xml_input).root.elements || []
    patches.collect do |patch_info|
      parse_headline(patch_info)
    end
  end
  
  def parse_headline(info)
    headline = Headline.new
    headline.author = author_from_darcs_id(info.attributes['author'])

    name = info.elements['name'].text
    comments = info.elements['comment']
    description = if name.strip.empty? then 'Untitled patch'; else name; end
    description += "\n" + comments.text if comments
    
    headline.description = description
    headline.happened_at = time_from_darcs_date(info.attributes['date'])
    headline.rid =  info.attributes['hash']
    headline.reported_by = self.name
    
    parse_changes(headline, @connection.diff(headline.rid))
    
    return headline
  end
  
  def parse_changes(headline, diffs)
    remain = diffs
    
    while(md = remain.match(/^diff[^\n]*\n--- old-[^\/]*\/([^\t]*)/))
      remain, diff = extract_diff(md.post_match)
      headline.changes.push Change.new(:summary => md[1],
                                       :diff => diff)
    end
  end
  
  def extract_diff(text)
    md = text.match(/^\+\+\+ [^\n]*\n/)

    remain, diff = '', md.post_match
    
    if (md = diff.match(/^diff/))
      remain, diff = md[0] + md.post_match, md.pre_match
    end
    
    return remain, diff
  end

end