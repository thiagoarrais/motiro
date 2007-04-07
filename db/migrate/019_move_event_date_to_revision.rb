class MoveEventDateToRevision < ActiveRecord::Migration

  def self.up
    add_column :revisions, :happens_at, :date
    execute("UPDATE revisions " +
            "SET happens_at = (select happens_at from pages p where p.id = page_id)")
  end
    
  def self.down
    remove_column :revisions, :happens_at
  end

end