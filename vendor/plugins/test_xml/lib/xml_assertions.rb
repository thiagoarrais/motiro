# Copyright (c) 2007 Thiago Arrais, distributed under the terms of the
# MIT-LICENSE

require 'rexml/rexml'

module XmlAssertions

  def assert_xml_element(xpath)
    assert_not_nil find_xml_element(xpath), "expected element, but found no element matching #{xpath} in #{@response.body.inspect}"
  end
  
  def assert_no_xml_element(xpath)
    assert_nil find_xml_element(xpath), "expected no element, but found element matching #{xpath} in #{@response.body.inspect}"
  end
  
private

  def find_xml_element(xpath)
    REXML::XPath.first(REXML::Document.new(@response.body), xpath)
  end

end
