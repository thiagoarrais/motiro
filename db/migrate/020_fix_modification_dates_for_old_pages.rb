class FixModificationDatesForOldPages < ActiveRecord::Migration

  def self.up
    Page.find(:all).each do |page|
      page.save
    end
  end
    
  def self.down; end

end