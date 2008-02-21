class ConvertLinkSyntax < ActiveRecord::Migration
  def self.up
    Revision.find(:all).each do |change|
      change.text.gsub!(/\[\[?(\w+)([ \t]+([^\]]+))?\]?\]/) do
        "[[#{$1}#{$2 ? '|' + $2.strip : ''}]]"
      end
      change.save
    end
  end
    
  def self.down; end
end
