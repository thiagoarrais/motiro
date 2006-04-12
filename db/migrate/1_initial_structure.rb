class InitialStructure < ActiveRecord::Migration

    def self.up
        create_table "headlines", :force => true do |t|
          t.column "author", :string, :limit => 40, :default => "", :null => false
          t.column "title", :string, :limit => 100, :default => "", :null => false
          t.column "happened_at", :timestamp
          t.column "reported_by", :string, :limit => 40, :default => "", :null => false
          t.column "rid", :string, :limit => 40, :default => "", :null => false
        end
      
        create_table "articles", :force => true do |t|
          t.column "headline_id", :integer, :default => 0, :null => false
          t.column "description", :text
        end
      
        add_index "articles", ["headline_id"], :name => "fk_article_headline"
      
        create_table "changes", :force => true do |t|
          t.column "article_id", :integer, :default => 0, :null => false
          t.column "summary", :text, :default => "", :null => false
          t.column "resource_kind", :string, :limit => 6
          t.column "diff", :text
        end
      
        add_index "changes", ["article_id"], :name => "fk_change_article"
      
    end
    

    def self.down
        drop_table 'changes'
        drop_table 'articles'
        drop_table 'headlines'
    end
end