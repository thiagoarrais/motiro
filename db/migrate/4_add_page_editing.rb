class AddPageEditing < ActiveRecord::Migration

    def self.up
        create_table "pages", :force => true do |t|
            t.column "name", :string, :default => '', :null => false
            t.column "text", :text, :default => '', :null => false
        end
    end
    

    def self.down
        drop_table "pages"
    end
end