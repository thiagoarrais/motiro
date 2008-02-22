class RegisterPageReferences < ActiveRecord::Migration
  def self.up
    Page.find(:all).each do |page|
      begin
        page.send :update_references, page.text
        page.save
      rescue; end      
    end
  end
    
  def self.down; end
end
