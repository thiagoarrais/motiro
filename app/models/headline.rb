class Headline < ActiveRecord::Base
  
  include Inflector
  
  has_many:changes
  
  def initialize(params={})
    params[:description] ||= ''
    if !params[:title].nil? then
      params[:description] = params[:title] + "\n\n" + params[:description]
      params.delete :title
    end
    super(params)
  end
  
  def self.latest(num, reporter)
    find(:all,
         :conditions => ["reported_by = ?", reporter],
         :order => 'happened_at DESC',
         :limit => num)
  end
  
  def self.find_with_reporter_and_rid(reporter_name, rid)
    find(:first,
         :conditions => ["reported_by = ? and rid = ?",
    reporter_name, rid])        
  end    
  
  def happened_at=(date_components)
    if date_components.is_a? Time
      self[:happened_at] = date_components
    else
      year, month, day, hour, min, sec = date_components
      self[:happened_at] = Time.local(year, month, day, hour, min, sec)
    end
  end
  
  def title(translator=Translator.default)
    description(translator).
      split($/).
      first || ''
  end
  
  def description(translator=Translator.default)
    translator.localize(self[:description])
  end
  
  # Saves the headline locally, if it isn't already cached
  def cache
    unless self.cached?
      self.class.destroy_all similar_to_self
      self.save
    end
  end
  
  def cached?
    cached_lines = Headline.find(:all,
                                 :conditions => similar_to_self)
    
    return false if cached_lines.empty?
    
    cached_lines.each do |hl| 
      return true if hl.filled?
    end
    
    return false
  end
  
  def filled?
    self.changes.each do |c|
      return false if !c.filled?
    end
    
    return true
  end
  
  def relative_to_now(reference_time=Time.now)
    secs = happened_at.to_i - reference_time.to_i
    sufix = if secs < 0 then 'ago' else 'from now' end
    secs = secs.abs
    result = nil
    # 31536000 = 86400 * 365 days (1 year)
    # 2592000 = 86400 * 30 days (1 month)
    # 604800 = 86400 seconds * 7 days (1 week)
    # 86400 = 60 seconds * 60 minutes * 24 h (1 day)
    # 3600 = 60 seconds * 60 minutes (1 hour)
    [ [31536000, 'year'], [2592000, 'month'], [604800, 'week'],
      [86400, 'day'], [3600, 'hour'], [60, 'minute']].
    each do |x|
      if result.nil? && secs >= x[0] then
        number = secs / x[0]
        result = filter_time_to(number, x[1], sufix)
      end
    end
    return result || 'Less than one minute ago'.t
  end
  
private
  
  def similar_to_self
    ["author = ? and description = ?and happened_at =?",
     self.author, self.description, self.happened_at]
  end

  def filter_time_to(number, period, sufix)
    return 'Yesterday'.t if 1 == number && 'day' == period && 'ago' == sufix
    return 'Tomorrow'.t if 1 == number && 'day' == period && 'from now' == sufix
    period = period.t
    inflected = if number > 1 then pluralize(period) else period end
    return "%s #{sufix}" / "#{number} #{inflected}"
  end
  
end
