class MigratePreviousEventData < ActiveRecord::Migration

  def self.up
    Headline.find(:all, :conditions => "reported_by = 'events'").each do |hl|
      author = User.find_by_login(hl.author)
      e = Event.new(:title => hl.title,
                    :name => hl.title.downcase.gsub(/ /, '_').camelize,
                    :text => hl.description,
                    :editors => '', :original_author => author, :kind => 'event',
                    :modified_at => Time.local(2007, 1, 22, 14, 35, 43),
                    :last_editor => author,
                    :happens_at => Date.civil(hl.happened_at.year,
                                              hl.happened_at.month,
                                              hl.happened_at.day))
      e.save
      hl.destroy
    end
  end
    
  def self.down
  end

end