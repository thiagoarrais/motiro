class AddTitleAndKindToPages < ActiveRecord::Migration
  
  def self.up
    add_column 'pages', 'kind', :text
    add_column 'pages', 'title', :text
  end
  
  def self.down
    remove_column 'pages', 'kind'
    remove_column 'pages', 'title'
  end
  
end