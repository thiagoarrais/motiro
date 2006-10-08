require 'rubygems'
require 'mediacloth'

class String
  
  def medialize
    MediaCloth::wiki_to_html self
  end
  
end