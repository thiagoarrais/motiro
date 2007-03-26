class DropRedundantPageColumns < ActiveRecord::Migration

  def self.up
    execute("INSERT INTO revisions (page_id, text, editors, kind, title, " +
                                   "modified_at, last_editor_id) " +
                         "SELECT id, text, editors, kind, title, " +
                                "'2006-02-01 00:00:00', original_author_id " +
                         "FROM   pages")
    execute("INSERT INTO revisions (page_id, text, editors, kind, title, " +
                                   "modified_at, last_editor_id) " +
                         "SELECT id, text, editors, kind, title, " +
                                "modified_at, last_editor_id " +
                         "FROM   pages")
    remove_column :pages, :text
    remove_column :pages, :editors
    remove_column :pages, :title
    remove_column :pages, :last_editor_id
    remove_column :pages, :original_author_id
  end
    
  def self.down
    raise IrreversibleMigration
  end

end