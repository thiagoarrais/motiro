class AddPageReferences < ActiveRecord::Migration
  def self.up
    create_table :wiki_references do |t|
      t.column 'referer_id', :integer
      t.column 'referee_id', :integer
    end
  end
    
  def self.down
    drop_table :wiki_references
  end
end