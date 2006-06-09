class Locale

  LANG_BREAK = /^--- (\S+) ----*\s*$/

  def self.default
    DefaultLocale.instance
  end
  
  def self.for(locale_code)
    return RealLocale.new(locale_code) unless locale_code.nil?
    return default
  end
  
  def localize(text); text; end
  
protected

  def initialize; end

end

class DefaultLocale < Locale

  include Singleton
  
  def localize(text)
    md = text.match(LANG_BREAK)
    return md.pre_match unless md.nil?
    return text
  end

end

class RealLocale < Locale

  def initialize(locale_code)
    @lang = locale_code
  end
  
  def localize(text)
    do_localize(text, default_text_from(text))
  end
  
private

  def do_localize(text, default)
    md = text.match(LANG_BREAK)
    if md.nil? then
      return default
    else
      return default_text_from(md.post_match) if @lang == md[1]
      return do_localize(md.post_match, default)
    end
  end
  
  def default_text_from(text)
    md = text.match(LANG_BREAK)
    return md.pre_match unless md.nil?
    return text
  end
  
end