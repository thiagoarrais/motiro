class AddFeatureStatus < ActiveRecord::Migration

  def self.up
    add_column :revisions, :done, :boolean, :default => 0 
  end
    
  def self.down
    remove_column :revisions, :done
  end

end
