require File.dirname(__FILE__) + '/../test_helper'

# Multiple languages can be specified for a page. Languages are identified
# by a line starting with three dashes, followed by a language/locale string 
# followed by three or more dashes.
# 
# lang_separator: '--- ' locale ' ---' ('-')*
class LocaleTest < Test::Unit::TestCase

  EN_ONLY = "This is the default locale text"

  EN_PT = "This is the default locale text\n\n" +
            "--- pt-BR -----\n\n" +
            "Este é o texto em português."
            
  EN_PT_DE = "Welcome to Motiro\n\n" +
             "--- pt-BR -----\n" +
             "Bem-vindo ao Motiro\n\n" +
             "--- de -----\n" +
             "Wilkommen zum Motiro"
            
  def test_default_locale_with_translation_available
    assert_equal "This is the default locale text\n\n",
                 Locale.default.localize(EN_PT)
  end
  
  def test_default_locale_without_available_translation
    assert_equal "This is the default locale text",
                 Locale.default.localize(EN_ONLY)
  end
  
  def test_resorts_to_default_locale_when_translation_not_available
    assert_equal "This is the default locale text\n\n",
                 Locale.for('de').localize(EN_PT)
    assert_equal "This is the default locale text",
                 Locale.for('de').localize(EN_ONLY)
  end
  
  def test_locates_right_translation_for_fully_matching_locale_code
    assert_equal "\nEste é o texto em português.",
                 Locale.for('pt-BR').localize(EN_PT)
    assert_equal "\nBem-vindo ao Motiro\n\n",
                 Locale.for('pt-BR').localize(EN_PT_DE)
    assert_equal "\nWilkommen zum Motiro",
                 Locale.for('de').localize(EN_PT_DE)
  end
  
  def test_nil_locale_code_is_the_same_as_default
    assert_same Locale.default, Locale.for(nil)
  end
  
  def text_recognizes_languages_with_carriage_return_characters
    input = "= Motiro =\n\nBem-vindo ao Motiro\n\r\n" +
            "--- en ---------\r\n" +
            "= Motiro =\n\nWelcome to Motiro\n\n" +
            "--- de ---------\n" +
            "= Motiro =\n\nWillkommen zum Motiro\n\n"
    assert_equal "= Motiro =\n\nBem-vindo ao Motiro\n\r\n",
                 Locale.default.localize(input)
    assert_equal "\n= Motiro =\n\nWelcome to Motiro\n\n",
                 Locale.for('en').localize(input)
  end
  
end