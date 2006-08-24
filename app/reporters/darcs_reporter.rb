require 'rubygems'
require 'xmlsimple'

require 'date'

require 'models/headline'

require 'core/reporter'

require 'reporters/darcs_connection'

class DarcsReporter < MotiroReporter

  def initialize(conn=DarcsConnection.new)
    @connection = conn
  end
  
  def latest_headlines
    parse_headlines(@connection.changes)
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
    Time.local(md[1].to_i, md[2].to_i, md[3].to_i,
               md[4].to_i, md[5].to_i, md[6].to_i)
  end
  
private

  def parse_headlines(xml_input)
    patches = XmlSimple.xml_in(xml_input)['patch'] || []
    patches.collect do |patch_info|
      parse_headline(patch_info)
    end
  end
  
  def parse_headline(info)
    headline = Headline.new
    headline.author = author_from_darcs_id(info['author'])

    name = info['name'].first
    comments = info['comment']
    description = if name.empty? then 'Untitled patch'
                                 else name; end
    description += "\n" + comments.first if comments
    
    headline.description = description
    headline.happened_at = time_from_darcs_date(info['date'])
    headline.rid =  info['hash']
    headline.reported_by = self.name
    
    return headline
  end

end