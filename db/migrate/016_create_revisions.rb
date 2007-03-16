class CreateRevisions < ActiveRecord::Migration

  def self.up
    create_table :revisions do |t|
      t.column 'page_id', :integer
      t.column 'text', :text
      t.column 'editors', :text
      t.column 'kind', :text
      t.column 'title', :text
      t.column 'created_at', :timestamp
      t.column 'revisor_id', :integer
    end
  end
    
  def self.down
    drop_table :revisions
  end

end