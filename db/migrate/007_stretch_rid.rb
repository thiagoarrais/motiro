class StretchRid < ActiveRecord::Migration

  def self.up
    change_column 'headlines', 'rid', :string, :limit => 255
  end
    
  def self.down
    change_column 'headlines', 'rid', :string, :limit => 40
  end

end