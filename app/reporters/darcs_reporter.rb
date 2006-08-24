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
    return [parse_headline(@connection.changes)]
  end
  
  def headline(rid)
    parse_headline(@connection.changes(rid))
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

  def parse_headline(xml_input)
    info = XmlSimple.xml_in(xml_input)['patch'].first
    
    headline = Headline.new
    headline.author = author_from_darcs_id(info['author'])

    description = info['name'].first
    description += "\n" + info['comment'].first if info['comment']
    
    headline.description = description
    headline.happened_at = time_from_darcs_date(info['date'])
    headline.rid =  info['hash']
    
    return headline
  end

end