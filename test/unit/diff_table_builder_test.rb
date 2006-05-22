require File.dirname(__FILE__) + '/../test_helper'
require 'diff_table_builder'

class DiffTableBuilderTest < Test::Unit::TestCase

    def test_renders_addition_only
        builder = DiffTableBuilder.new

        builder.push_addition 'I have added this'
        
        expected_diff_table = "<table cellspacing='0'>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>1</td>\n" +
                              "    <td />\n" +
                              "    <td class='added' style='border:solid; border-width: 0 0 0 1px;'><pre>I have added this</pre></td>\n" +
                              "  </tr>\n" +
                              "</table>"
        
        assert_equal expected_diff_table, builder.render_diff_table
    end

    def test_matches_alterning_addition_and_deletion
        builder = DiffTableBuilder.new

        builder.push_deletion 'I have removed this'
        builder.push_addition 'I have added this'
        
        expected_diff_table = "<table cellspacing='0'>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>1</td>\n" +
                              "    <td class='removed' style='border:solid; border-width: 0 0 0 1px;'><pre>I have removed this</pre></td>\n" +
                              "    <td class='added' style='border:solid; border-width: 0 0 0 1px;'><pre>I have added this</pre></td>\n" +
                              "  </tr>\n" +
                              "</table>"
        
        assert_equal expected_diff_table, builder.render_diff_table
    end
    
end