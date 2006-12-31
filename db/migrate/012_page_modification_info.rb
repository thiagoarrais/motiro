class PageModificationInfo < ActiveRecord::Migration
  
  def self.up
    add_column 'pages', 'modified_at', :timestamp
    add_column 'pages', 'last_editor_id', :integer
  end
  
  def self.down
    remove_column 'pages', 'modified_at'
    remove_column 'pages', 'last_editor_id'
  end
  
end