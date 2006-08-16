require 'rubygems'
require 'xmlsimple'

require 'date'

require 'models/headline'

require 'core/reporter'

class DarcsReporter < MotiroReporter

  def initialize(conn=DarcsConnection.new)
    @connection = conn
  end
  
  def latest_headlines
    info = XmlSimple.xml_in(@connection.changes)['patch'].first
    
    headline = Headline.new
    headline.author = author_from_darcs_id(info['author'])
    headline.description = info['name'].first
    
    return [headline]
  end
  
  def author_from_darcs_id(id)
    md = id.match(/@/)
    return md.pre_match if md
  end

end