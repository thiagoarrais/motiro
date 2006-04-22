class DropArticles < ActiveRecord::Migration

    def self.up
        add_column 'headlines', "description", :text
        remove_index 'changes', :name => 'fk_change_article'
        rename_column 'changes', 'article_id', 'headline_id'
        add_index "changes", ["headline_id"], :name => "fk_change_headline"
        drop_table 'articles'
    end
    

    def self.down
        create_table "articles", :force => true do |t|
          t.column "headline_id", :integer, :default => 0, :null => false
          t.column "description", :text
        end

        add_index "articles", ["headline_id"], :name => "fk_article_headline"
        
        remove_index 'changes', :name => 'fk_change_headline'
        rename_column 'changes', 'headline_id', 'article_id'
        add_index "changes", ["article_id"], :name => "fk_change_article"
        
        remove_column 'headlines', 'descrition'
    end
end