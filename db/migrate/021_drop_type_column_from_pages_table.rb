class DropTypeColumnFromPagesTable < ActiveRecord::Migration

  def self.up
    remove_column :pages, :type
  end
    
  def self.down;
    raise IrreversibleMigration
  end

end