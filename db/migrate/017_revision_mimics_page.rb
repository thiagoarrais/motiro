class RevisionMimicsPage < ActiveRecord::Migration

  def self.up
    rename_column :revisions, :revisor_id, :last_editor_id
    rename_column :revisions, :created_at, :modified_at
  end
    
  def self.down
    rename_column :revisions, :last_editor_id, :revisor_id
    rename_column :revisions, :modified_at, :created_at
  end

end