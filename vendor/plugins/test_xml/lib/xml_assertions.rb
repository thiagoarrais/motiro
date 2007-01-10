# Copyright (c) 2007 Thiago Arrais, distributed under the terms of the
# MIT-LICENSE

require 'rexml/rexml'

module XmlAssertions

  def assert_xml_element(xpath)
    doc = REXML::Document.new(@response.body)
    assert REXML::XPath.first(doc, xpath), "expected element, but found no element matching #{xpath} in #{@response.body.inspect}"
  end

end
