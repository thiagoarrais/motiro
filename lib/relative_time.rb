class Time

  def relative_to_now(reference_time=Time.now)
    secs = self.to_i - reference_time.to_i
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

  include Inflector

  def filter_time_to(number, period, sufix)
    return 'Yesterday'.t if 1 == number && 'day' == period && 'ago' == sufix
    return 'Tomorrow'.t if 1 == number && 'day' == period && 'from now' == sufix
    period = period.t
    inflected = if number > 1 then pluralize(period) else period end
    return "%s #{sufix}" / "#{number} #{inflected}"
  end

end
