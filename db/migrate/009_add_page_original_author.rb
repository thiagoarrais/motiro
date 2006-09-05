class AddPageOriginalAuthor < ActiveRecord::Migration

  def self.up
    add_column 'pages', 'original_author_id', :integer, :default => :null
  end
    

  def self.down
    remove_column 'pages', 'original_author_id'
  end

end