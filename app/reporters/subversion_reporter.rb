#  Motiro - A project tracking tool
#  Copyright (C) 2006  Thiago Arrais
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

require 'rubygems'
require 'xmlsimple'

require 'date'
require 'reporters/svn_connection'

require 'models/headline'

require 'core/reporter'

class String
  
  def to_rev_num
    self.match(/\d+/)[0]
  end
  
end

class SubversionReporter < MotiroReporter
  
  use_toolbar 'report/more_toolbar'
  
  def initialize(connection = SubversionConnection.new)
    @connection = connection
  end
  
  def latest_headlines
    build_headlines_from(@connection.log)
  end
  
  def headlines
    build_headlines_from(@connection.log(:no_limit))
  end
  
  def headline(rid)
    revision_id = rid.match(/^r(.+)/)[1]
    
    output = @connection.log(revision_id)
    
    result_headline, remain = build_headline_from(output)
    
    return result_headline
  end
  
private
  
  def build_headlines_from(text)
    remain = text
    hls = Array.new
    
    hl = 0
    until hl.nil? do
      hl, remain = build_headline_from(remain)
      unless hl.nil?
        hl.reported_by = self.name
        hls.push hl
      end
    end
    return hls
  end

  def build_headline_from(text)
    begin
      result = Headline.new
      
      result, remain = consume_dashes(result, text)
      result, remain = parse_header(result, remain)
      result, remain = parse_changed_resources(result, remain)
      result, remain = parse_description(result, remain)
      
      return result, remain
    rescue
      return nil
    end
  end
  
  def consume_dashes(theHeadline, text)
    remain = /^-+\n/.match(text).post_match
    return theHeadline, remain
  end
  
  def parse_header(theHeadline, text)
    md = text.match /^(r\d+)\s*\|\s*(\w+)\s*\|\s(\d+)-(\d+)-(\d+)\s+(\d+):(\d+):(\d+)[^|]*\|\s*(\d+)\s*[^\n]*\n/
    remain = md.post_match
    
    theHeadline.rid = md[1]
    theHeadline.author = md[2]
    theHeadline.happened_at = md[3..8].collect do |s| s.to_i end
    
    return theHeadline, remain
  end
  
  def parse_changed_resources(theHeadline, text)
    remain = text
    
    changes = theHeadline.changes
    
    # skip the first line with the title 'Changed resources' (or something
    # like this)
    remain = remain.match(/\n/).post_match
    
    md = remain.match(/^\n/)
    resources = md.pre_match
    remain = md.post_match
    
    while('' != resources) do
      md = resources.match(/\n/)
      resources = md.post_match

      summary = md.pre_match
      resource_path = summary.match(/\w ([^\s]+)/)[1]
      diff = diff_for(resource_path, theHeadline.rid)
      kind = kind_of(resource_path, theHeadline.rid)
      changes.push(Change.new(:summary => summary,
                              :resource_kind => kind,
                              :diff => diff))
    end
      
    return theHeadline, remain
  end
    
  def diff_for(resource_path, revision_id)
    revision_num = revision_id.to_rev_num

    remain = @connection.diff(revision_num)

    while(md = remain.match(/^Index: ([^\n]+)$/)) do
      remain = md.post_match
      if resource_path.include?(md[1])
        diff_text = md[0]
        if (md = remain.match(/^Index:/))
          diff_text += md.pre_match
        else
          diff_text += remain
        end
        return svn_parse_diff(diff_text)
      end
    end
  end
      
  def kind_of(resource_path, revision_id)
    revision_num = revision_id.to_rev_num

    begin
      raw_info = @connection.info(resource_path, revision_num)
      info = XmlSimple.xml_in(raw_info)
          
      return info['entry'].first['kind']
    rescue
      return nil
    end
  end
      
  def svn_parse_diff(text)
    remain = text
    md = text.match(/Index: [^\n]+$/)
    remain = md.post_match
        
    1.upto 4 do
      remain = /\n/.match(remain).post_match
    end

    if (md = remain.match(/^Index:/))
      return md.pre_match
    else
      return remain
    end
  end
      
  def parse_description(theHeadline, text)
    md = /\n-+\n/.match(text)
    theHeadline.description = md.pre_match

    remain = md[0] + md.post_match

    return theHeadline, remain
  end
      
  # consumes lines until a line matching the given regexp is found
  def consume_until(regexp, text)
    theRegexp = Regexp.new("^#{regexp}\n")
    remain = text

    while(!remain.match(theRegexp)) do
      remain = remain.match(/\n/.post_match)
    end

    return remain
  end

end
