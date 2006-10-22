class RemoveEmptyStringDefaultsFromPages < ActiveRecord::Migration
  
  def self.up
    rename_table 'pages', 'pages_old'
    create_table 'pages', :force => true do |t|
      t.column "name", :string, :null => false
      t.column "text", :text, :null => false
      t.column 'editors', :text, :null => false
      t.column 'original_author_id', :integer
    end
	execute 'INSERT INTO pages (name, text, editors, original_author_id) SELECT name, text, editors, original_author_id FROM pages_old'
	drop_table 'pages_old'
  end
  
  def self.down; end
  
end