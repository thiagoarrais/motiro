class ProvideRevisionPosition < ActiveRecord::Migration

  def self.up
    add_column :revisions, :position, :integer
    Page.find(:all).each do |pg|
      position = 0
      pg.revisions.each do |rev|
        rev.position = position
        rev.save
        position += 1
      end
    end
  end
    
  def self.down;
    remove_column :revisions, :position
  end

end
