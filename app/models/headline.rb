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

class Headline < ActiveRecord::Base
  
  has_many :changes, :dependent => :destroy
  
  def initialize(params={})
    params[:description] ||= ''
    if !params[:title].nil? then
      params[:description] = params[:title] + "\n\n" + params[:description]
      params.delete :title
    end
    super(params)
  end
  
  def self.latest(num, reporter)
    find(:all,
         :conditions => ["reported_by = ?", reporter],
         :order => 'happened_at DESC',
         :limit => num)
  end
  
  def self.find_with_reporter_and_rid(reporter_name, rid)
    find(:first,
         :conditions => ["reported_by = ? and rid = ?",
    reporter_name, rid])        
  end    
  
  def happened_at=(date_components)
    if date_components.is_a? Time
      self[:happened_at] = date_components
    else
      year, month, day, hour, min, sec = date_components
      self[:happened_at] = Time.local(year, month, day, hour, min, sec)
    end
  end
  
  def title(translator=Translator.default)
    answer = description(translator).
               split($/).
               first || ''
    answer.strip
  end
  
  def description(translator=Translator.default)
    translator.localize(self[:description])
  end
  
  # Saves the headline locally, if it isn't already cached
  def cache
    unless self.cached?
      self.class.destroy_all similar_to_self
      self.save
    end
  end
  
  def cached?
    cached_lines = Headline.find(:all,
                                 :conditions => similar_to_self)
    
    return false if cached_lines.empty?
    
    cached_lines.each do |hl| 
      return true if hl.filled?
    end
    
    return false
  end
  
  def filled?
    self.changes.each do |c|
      return false if !c.filled?
    end
    
    return true
  end
  
private
  
  def similar_to_self
    ["author = ? and description = ? and happened_at =?",
     self[:author], self[:description], self[:happened_at]]
  end

end
