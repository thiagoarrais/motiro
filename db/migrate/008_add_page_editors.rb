class AddPageEditors < ActiveRecord::Migration

  def self.up
    add_column 'pages', 'editors', :text, :default => "", :null => false
  end
    

  def self.down
    remove_column 'pages', 'editors'
  end

end