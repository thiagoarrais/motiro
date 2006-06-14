require File.dirname(__FILE__) + '/../test_helper'

# Multiple languages can be specified for a page. Languages are identified
# by a line starting with three dashes, followed by a language/locale string 
# followed by three or more dashes.
# 
# lang_separator: '--- ' locale ' ---' ('-')*
class TranslatorTest < Test::Unit::TestCase

  EN_ONLY = "This is the default locale text"

  EN_PT = "This is the default locale text\n\n" +
            "--- pt-BR -----\n\n" +
            "Este é o texto em português."
            
  EN_PT_DE = "Welcome to Motiro\n\n" +
             "--- pt-BR -----\n" +
             "Bem-vindo ao Motiro\n\n" +
             "--- de -----\n" +
             "Wilkommen zum Motiro"
            
  EN_PT_PT = "Motiro updated\n\n" +
             "--- pt-BR -----\n" +
             "Motiro atualizado\n\n" +
             "--- pt-PT -----\n" +
             "Motiro actualizado"

  def test_default_locale_with_translation_available
    assert_equal "This is the default locale text\n\n",
                 Translator.default.localize(EN_PT)
  end
  
  def test_default_locale_without_available_translation
    assert_equal "This is the default locale text",
                 Translator.default.localize(EN_ONLY)
  end
  
  def test_resorts_to_default_locale_when_translation_not_available
    assert_equal "This is the default locale text\n\n",
                 Translator.for('de').localize(EN_PT)
    assert_equal "This is the default locale text",
                 Translator.for('de').localize(EN_ONLY)
  end
  
  def test_locates_right_translation_for_fully_matching_locale_code
    assert_equal "\nEste é o texto em português.",
                 Translator.for('pt-BR').localize(EN_PT)
    assert_equal "\nBem-vindo ao Motiro\n\n",
                 Translator.for('pt-BR').localize(EN_PT_DE)
    assert_equal "\nWilkommen zum Motiro",
                 Translator.for('de').localize(EN_PT_DE)
  end
  
  def test_locates_right_translation_using_language_code_only
    assert_equal "\nEste é o texto em português.",
                 Translator.for('pt').localize(EN_PT)
    assert_equal "\nBem-vindo ao Motiro\n\n",
                 Translator.for('pt').localize(EN_PT_DE)
  end
  
  def test_resorts_to_matching_language_code_only_when_locale_not_found
    assert_equal "\nBem-vindo ao Motiro\n\n",
                 Translator.for('pt-AO').localize(EN_PT_DE)
  end
  
  def test_locates_most_specific_locale_when_available
    assert_equal "\nMotiro actualizado",
                 Translator.for('pt-PT').localize(EN_PT_PT)
  end
  
  def test_nil_locale_code_is_the_same_as_default
    assert_same Translator.default, Translator.for(nil)
  end
  
  def text_recognizes_languages_with_carriage_return_characters
    input = "= Motiro =\n\nBem-vindo ao Motiro\n\r\n" +
            "--- en ---------\r\n" +
            "= Motiro =\n\nWelcome to Motiro\n\n" +
            "--- de ---------\n" +
            "= Motiro =\n\nWillkommen zum Motiro\n\n"
    assert_equal "= Motiro =\n\nBem-vindo ao Motiro\n\r\n",
                 Translator.default.localize(input)
    assert_equal "\n= Motiro =\n\nWelcome to Motiro\n\n",
                 Translator.for('en').localize(input)
  end
  
end