require File.dirname(__FILE__) + '/../test_helper'

class StringExtensionsTest < Test::Unit::TestCase

  def test_medialize
    str = "= Motiro =\n\nAnother paragraph"
    assert_equal '<h1>Motiro</h1><p>Another paragraph</p>', str.medialize
  end

end