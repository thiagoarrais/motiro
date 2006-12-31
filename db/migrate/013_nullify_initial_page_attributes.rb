class NullifyInitialPageAttributes < ActiveRecord::Migration

  def self.up
    rename_table 'pages', 'pages_old'
    create_table 'pages', :force => true do |t|
      t.column "name", :string
      t.column "text", :text
      t.column 'editors', :text
      t.column 'original_author_id', :integer
      t.column 'kind', :text
      t.column 'title', :text
      t.column 'modified_at', :timestamp
      t.column 'last_editor_id', :integer
    end
	execute 'INSERT INTO pages (name, text, editors, original_author_id, kind, title, modified_at, last_editor_id) SELECT name, text, editors, original_author_id, kind, title, modified_at, last_editor_id FROM pages_old'
	drop_table 'pages_old'
  end
    
  def self.down; end

end