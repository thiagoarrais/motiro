class RemoveHeadlineTitle < ActiveRecord::Migration

  def self.up
    remove_column 'headlines', 'title'
    add_index 'headlines', 'rid'
  end
    

  def self.down
    remove_index 'headlines', 'rid'
    add_column 'headlines', 'title', :string, :limit => 100, :default => "", :null => false
  end

end