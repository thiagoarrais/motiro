# Copyright (c) 2007 Thiago Arrais, distributed under the terms of the
# MIT-LICENSE

unless defined?(RAILS_ROOT)
 RAILS_ROOT = ENV["RAILS_ROOT"] || File.expand_path(File.join(File.dirname(__FILE__), "../../../.."))
end
require File.join(RAILS_ROOT, "test", "test_helper")
require File.join(File.dirname(__FILE__), "..", "init")

class TestXmlTest < Test::Unit::TestCase

  SHALLOW_ELEMENT_XML = <<END
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <element>Element text</element>
</root>
END
  
  def setup
    @response = ActionController::TestResponse.new
  end

  def test_find_xml_tag_by_xpath
    @response.body = SHALLOW_ELEMENT_XML
    assert_raise Test::Unit::AssertionFailedError do
      assert_xml_element '//absent'
    end

    assert_xml_element '//element'
  end

end
