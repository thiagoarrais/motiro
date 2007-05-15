class IncrementRevisionPositions < ActiveRecord::Migration

  def self.up
    execute('UPDATE revisions SET position = position + 1')
  end
    
  def self.down;
    execute('UPDATE revisions SET position = position - 1')
  end

end
