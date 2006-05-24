require File.dirname(__FILE__) + '/../test_helper'
require 'diff_table_builder'

class DiffTableBuilderTest < Test::Unit::TestCase

    def setup
        @builder = DiffTableBuilder.new
    end

    def test_renders_addition_only
        @builder.push_addition 'I have added this'
        
        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>1</td>\n" +
            "    <td style='border:solid; " +
                           "border-width: 1px 1px 1px 1px; " +
                           "border-color: black gray black black'>&nbsp;" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 1px 1px 1px 0;'>" +
                  "<pre>I have added this</pre>" +
                "</td>\n" +
            "  </tr>\n" +
            "</table>"
        
        assert_equal expected_diff_table, @builder.render_diff_table
    end

    def test_renders_deletion_only
        @builder.push_deletion 'I have removed this'
        
        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>1</td>\n" +
            "    <td class='changed' " +
                    "style='border:solid; " +
                           "border-width: 1px 1px 1px 1px; " +
                           "border-color: black gray black black'>" +
                  "<pre>I have removed this</pre>" +
                "</td>\n" +
            "    <td style='border:solid black; " +
                           "border-width: 1px 1px 1px 0;'>&nbsp;</td>\n" +
            "  </tr>\n" +
            "</table>"
        
        assert_equal expected_diff_table, @builder.render_diff_table
    end

    def test_matches_alterning_addition_and_deletion
        @builder.push_deletion 'I have removed this'
        @builder.push_addition 'I have added this'
        
        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>1</td>\n" +
            "    <td class='changed' " +
                    "style='border:solid; " +
                           "border-width: 1px 1px 1px 1px; " +
                           "border-color: black gray black black'>" +
                  "<pre>I have removed this</pre>" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 1px 1px 1px 0;'>" +
                  "<pre>I have added this</pre>" +
                "</td>\n" +
            "  </tr>\n" +
            "</table>"
        
        assert_equal expected_diff_table, @builder.render_diff_table
    end
    
    def test_multiline_modification
        @builder.push_deletion 'This is the first old line'
        @builder.push_deletion 'This is the second old line'
        @builder.push_addition 'This is the first new line'
        @builder.push_addition 'This is the second new line'

        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>1</td>\n" +
            "    <td class='changed' " +
                    "style='border:solid; " +
                           "border-width: 1px 1px 0 1px; " +
                           "border-color: black gray black black'>" +
                  "<pre>This is the first old line</pre>" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 1px 1px 0 0;'>" +
                  "<pre>This is the first new line</pre>" +
                "</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>2</td>\n" +
            "    <td class='changed' " +
                    "style='border:solid; " +
                           "border-width: 0 1px 1px 1px; " +
                           "border-color: black gray black black'>" +
                  "<pre>This is the second old line</pre>" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 0 1px 1px 0;'>" +
                  "<pre>This is the second new line</pre>" +
                "</td>\n" +
            "  </tr>\n" +
            "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end
    
    def test_more_adds_than_deletes
        @builder.push_deletion 'This is the first old line'
        @builder.push_addition 'This is the first new line'
        @builder.push_addition 'This is the second new line'

        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>1</td>\n" +
            "    <td class='changed' " +
                    "style='border:solid; " +
                           "border-width: 1px 1px 1px 1px; " +
                           "border-color: black gray black black'>" +
                  "<pre>This is the first old line</pre>" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 1px 1px 0 0;'>" +
                  "<pre>This is the first new line</pre>" +
                "</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>2</td>\n" +
            "    <td style='border:solid; " +
                           "border-width: 0 1px 0 0; " +
                           "border-color: black gray black black'>&nbsp;" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 0 1px 1px 1px;'>" +
                  "<pre>This is the second new line</pre>" +
                "</td>\n" +
            "  </tr>\n" +
            "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end
    
    def test_less_adds_than_deletes
        @builder.push_deletion 'This is the first old line'
        @builder.push_deletion 'This is the second old line'
        @builder.push_addition 'This is the first new line'

        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>1</td>\n" +
            "    <td class='changed' " +
                    "style='border:solid; " +
                           "border-width: 1px 1px 0 1px; " +
                           "border-color: black gray black black'>" +
                  "<pre>This is the first old line</pre>" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 1px 1px 1px 0;'>" +
                  "<pre>This is the first new line</pre>" +
                "</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>2</td>\n" +
            "    <td class='changed' " +
                    "style='border:solid; " +
                           "border-width: 0 1px 1px 1px; " +
                           "border-color: black gray black black'>" +
                  "<pre>This is the second old line</pre>" +
                "</td>\n" +
            "    <td style='border:solid black; " +
                           "border-width: 0 0 0 1px;'>&nbsp;" +
                "</td>\n" +
            "  </tr>\n" +
            "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end

    def test_some_code_kept
        @builder.push_unchanged 'div.channel-title {'
        @builder.push_deletion  '    font: normal 8pt Verdana,sans-serif;'
        @builder.push_addition  '    font: bold 10pt Verdana,sans-serif;'
        @builder.push_unchanged '    margin:0 0 0 0;'
        
        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>1</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 1px 0 0;'>" +
                  "<pre>div.channel-title {</pre>" +
                "</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 0 0 0;'>" +
                  "<pre>div.channel-title {</pre>" +
                "</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>2</td>\n" +
            "    <td class='changed' " +
                    "style='border:solid; " +
                           "border-width: 1px 1px 1px 1px; " +
                           "border-color: black gray black black'>" +
                  "<pre>    font: normal 8pt Verdana,sans-serif;</pre>" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 1px 1px 1px 0;'>" +
                  "<pre>    font: bold 10pt Verdana,sans-serif;</pre>" +
                "</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>3</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 1px 0 0;'>" +
                  "<pre>    margin:0 0 0 0;</pre>" +
                "</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 0 0 0;'>" +
                  "<pre>    margin:0 0 0 0;</pre>" +
                "</td>\n" +
            "  </tr>\n" +
            "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end
    
    def test_addition_to_existent_code
        @builder.push_unchanged 'This line will be kept'
        @builder.push_addition 'This line was added'

        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>1</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 1px 0 0;'>" +
                  "<pre>This line will be kept</pre>" +
                "</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 0 0 0;'>" +
                  "<pre>This line will be kept</pre>" +
                "</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>2</td>\n" +
            "    <td style='border:solid; " +
                           "border-width: 1px 1px 1px 1px; " +
                           "border-color: black gray black black'>&nbsp;" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 1px 1px 1px 0;'>" +
                  "<pre>This line was added</pre>" +
                "</td>\n" +
            "  </tr>\n" +
            "</table>"
        
        assert_equal expected_diff_table, @builder.render_diff_table
    end
    
    def test_escapes_html
        @builder.push_unchanged '        <h1><%= h(@headline.title) -%></h1>'
        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td style='text-align: center; " +
                           "border:solid gray; " +
                           "border-width: 0 1px 0 0;'>1</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 1px 0 0;'>" +
    "<pre>        &lt;h1&gt;&lt;%= h(@headline.title) -%&gt;&lt;/h1&gt;</pre>" +
                "</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 0 0 0;'>" +
    "<pre>        &lt;h1&gt;&lt;%= h(@headline.title) -%&gt;&lt;/h1&gt;</pre>" +
                "</td>\n" +
            "  </tr>\n" +
            "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end
end