class Translator

  LANG_BREAK = /^--- (\S+) ----*\s*$/

  def self.default
    DefaultTranslator.instance
  end
  
  def self.for(locale_code)
    return RealTranslator.new(locale_code) unless locale_code.nil?
    return default
  end
  
  def localize(text); text; end
  
protected

  def initialize; end

end

class DefaultTranslator < Translator

  include Singleton
  
  def localize(text)
    md = text.match(LANG_BREAK)
    return md.pre_match unless md.nil?
    return text
  end

end

class RealTranslator < Translator

  attr_accessor :lang, :locale

  def initialize(locale_code)
    md = locale_code.match(/([^-]+)(-(.*))?/)
    self.lang = md[1]
    self.locale = md[3]
  end
  
  def localize(text)
    md = text.match(/^--- #{lang}-#{locale} ----*\s*$/)
    md = text.match(/^--- #{lang} ----*\s*$/) if md.nil?
    md = text.match(/^--- #{lang}-\S+ ----*\s*$/) if md.nil?
    return default_text_from(text) if md.nil?
    return default_text_from(md.post_match)
  end
  
  def ==(other)
    return other.kind_of?(RealLocale) &&
           lang == other.lang &&
           locale == other.locale
  end
  
private

  def default_text_from(text)
    md = text.match(LANG_BREAK)
    return md.pre_match unless md.nil?
    return text
  end
  
end