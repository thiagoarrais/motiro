class EventsAreWikiPages < ActiveRecord::Migration

  def self.up
    add_column('pages', 'type', :string)
    add_column('pages', 'happens_at', :date)
  end
    
  def self.down
    remove_column('pages', 'type')
    remove_column('pages', 'happens_at')
  end

end