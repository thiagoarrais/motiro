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
            "    <td class='line_number'>&nbsp;</td>\n" +
            "    <td style='border:solid; " +
                           "border-width: 1px 1px 1px 1px; " +
                           "border-color: black gray black black'>&nbsp;" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 1px 1px 1px 0;'>" +
                  "<pre>I have added this</pre>" +
                "</td>\n" +
            "    <td class='line_number'>1</td>\n" +
            "  </tr>\n" +
            "</table>"
        
        assert_equal expected_diff_table, @builder.render_diff_table
    end

    def test_renders_deletion_only
        @builder.push_deletion 'I have removed this'
        
        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>1</td>\n" +
            "    <td class='changed' " +
                    "style='border:solid; " +
                           "border-width: 1px 1px 1px 1px; " +
                           "border-color: black gray black black'>" +
                  "<pre>I have removed this</pre>" +
                "</td>\n" +
            "    <td style='border:solid black; " +
                           "border-width: 1px 1px 1px 0;'>&nbsp;</td>\n" +
            "    <td class='line_number'>&nbsp;</td>\n" +
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
            "    <td class='line_number'>1</td>\n" +
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
            "    <td class='line_number'>1</td>\n" +
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
            "    <td class='line_number'>1</td>\n" +
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
            "    <td class='line_number'>1</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>2</td>\n" +
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
            "    <td class='line_number'>2</td>\n" +
            "  </tr>\n" +
            "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end
    
    def test_more_adds_than_deletes
        @builder.push_deletion  'This is the first old line'
        @builder.push_addition  'This is the first new line'
        @builder.push_addition  'This is the second new line'
        @builder.push_unchanged 'This line remains the same'

        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>1</td>\n" +
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
            "    <td class='line_number'>1</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>&nbsp;</td>\n" +
            "    <td style='border:solid; " +
                           "border-width: 0 1px 0 0; " +
                           "border-color: black gray black black'>&nbsp;" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 0 1px 1px 1px;'>" +
                  "<pre>This is the second new line</pre>" +
                "</td>\n" +
            "    <td class='line_number'>2</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>2</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 1px 0 0;'>" +
                  "<pre>This line remains the same</pre>" +
                "</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 0 0 0;'>" +
                  "<pre>This line remains the same</pre>" +
                "</td>\n" +
            "    <td class='line_number'>3</td>\n" +
            "  </tr>\n" +
            "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end
    
    def test_less_adds_than_deletes
        @builder.push_deletion 'This is the first old line'
        @builder.push_deletion 'This is the second old line'
        @builder.push_addition 'This is the first new line'
        @builder.push_unchanged 'This line remains the same'

        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>1</td>\n" +
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
            "    <td class='line_number'>1</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>2</td>\n" +
            "    <td class='changed' " +
                    "style='border:solid; " +
                           "border-width: 0 1px 1px 1px; " +
                           "border-color: black gray black black'>" +
                  "<pre>This is the second old line</pre>" +
                "</td>\n" +
            "    <td style='border:solid black; " +
                           "border-width: 0 0 0 1px;'>&nbsp;" +
                "</td>\n" +
            "    <td class='line_number'>&nbsp;</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>3</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 1px 0 0;'>" +
                  "<pre>This line remains the same</pre>" +
                "</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 0 0 0;'>" +
                  "<pre>This line remains the same</pre>" +
                "</td>\n" +
            "    <td class='line_number'>2</td>\n" +
            "  </tr>\n" +
            "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end

    def test_some_code_kept
        @builder.start_line 6

        @builder.push_unchanged 'div.channel-title {'
        @builder.push_deletion  '    font: normal 8pt Verdana,sans-serif;'
        @builder.push_addition  '    font: bold 10pt Verdana,sans-serif;'
        @builder.push_unchanged '    margin:0 0 0 0;'
        
        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>6</td>\n" +
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
            "    <td class='line_number'>6</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>7</td>\n" +
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
            "    <td class='line_number'>7</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>8</td>\n" +
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
            "    <td class='line_number'>8</td>\n" +
            "  </tr>\n" +
            "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end
    
    def test_esparse_changes
        @builder.start_line 6

        @builder.push_unchanged 'div.channel-title {'
        @builder.push_deletion  '    font: normal 8pt Verdana,sans-serif;'
        @builder.push_addition  '    font: bold 10pt Verdana,sans-serif;'
        @builder.push_unchanged '    margin:0 0 0 0;'
        
        @builder.start_line 13

        @builder.push_unchanged 'div.channel-body-outer {'
        @builder.push_deletion  '    padding: 0 9px 0 9px;'
        @builder.push_addition  '    padding: 0 8px 0 8px;'
        @builder.push_unchanged '}'

        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>6</td>\n" +
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
            "    <td class='line_number'>6</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>7</td>\n" +
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
            "    <td class='line_number'>7</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>8</td>\n" +
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
            "    <td class='line_number'>8</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td style='border:solid gray; " +
                           "border-width: 1px 0 1px 0;'>&nbsp;</td>\n" +
            "    <td style='border:solid gray; " +
                           "border-width: 1px 0 1px 0;'>&nbsp;</td>\n" +
            "    <td style='border:solid gray; " +
                           "border-width: 1px 0 1px 0;'>&nbsp;</td>\n" +
            "    <td style='border:solid gray; " +
                           "border-width: 1px 0 1px 0;'>&nbsp;</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>13</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 1px 0 0;'>" +
                  "<pre>div.channel-body-outer {</pre>" +
                "</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 0 0 0;'>" +
                  "<pre>div.channel-body-outer {</pre>" +
                "</td>\n" +
            "    <td class='line_number'>13</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>14</td>\n" +
            "    <td class='changed' " +
                    "style='border:solid; " +
                           "border-width: 1px 1px 1px 1px; " +
                           "border-color: black gray black black'>" +
                  "<pre>    padding: 0 9px 0 9px;</pre>" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 1px 1px 1px 0;'>" +
                  "<pre>    padding: 0 8px 0 8px;</pre>" +
                "</td>\n" +
            "    <td class='line_number'>14</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>15</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 1px 0 0;'>" +
                  "<pre>}</pre>" +
                "</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 0 0 0;'>" +
                  "<pre>}</pre>" +
                "</td>\n" +
            "    <td class='line_number'>15</td>\n" +
            "  </tr>\n" +
            "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end

    def test_unmatching_line_numbers
        @builder.start_line(6, 6)

        @builder.push_unchanged 'div.channel-title {'
        @builder.push_deletion  '    font: normal 8pt Verdana,sans-serif;'
        @builder.push_addition  '    font: bold 10pt Verdana,sans-serif;'
        @builder.push_addition  '    margin:0 0 0 0;'
        
        @builder.start_line(13, 14)

        @builder.push_unchanged 'div.channel-body-outer {'
        @builder.push_deletion  '    padding: 0 9px 0 9px;'
        @builder.push_addition  '    padding: 0 8px 0 8px;'
        @builder.push_unchanged '}'

        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>6</td>\n" +
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
            "    <td class='line_number'>6</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>7</td>\n" +
            "    <td class='changed' " +
                    "style='border:solid; " +
                           "border-width: 1px 1px 1px 1px; " +
                           "border-color: black gray black black'>" +
                  "<pre>    font: normal 8pt Verdana,sans-serif;</pre>" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 1px 1px 0 0;'>" +
                  "<pre>    font: bold 10pt Verdana,sans-serif;</pre>" +
                "</td>\n" +
            "    <td class='line_number'>7</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>&nbsp;</td>\n" +
            "    <td style='border:solid; " +
                           "border-width: 0 1px 0 0; " +
                           "border-color: black gray black black'>&nbsp;" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 0 1px 1px 1px;'>" +
                  "<pre>    margin:0 0 0 0;</pre>" +
                "</td>\n" +
            "    <td class='line_number'>8</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td style='border:solid gray; " +
                           "border-width: 1px 0 1px 0;'>&nbsp;</td>\n" +
            "    <td style='border:solid gray; " +
                           "border-width: 1px 0 1px 0;'>&nbsp;</td>\n" +
            "    <td style='border:solid gray; " +
                           "border-width: 1px 0 1px 0;'>&nbsp;</td>\n" +
            "    <td style='border:solid gray; " +
                           "border-width: 1px 0 1px 0;'>&nbsp;</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>13</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 1px 0 0;'>" +
                  "<pre>div.channel-body-outer {</pre>" +
                "</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 0 0 0;'>" +
                  "<pre>div.channel-body-outer {</pre>" +
                "</td>\n" +
            "    <td class='line_number'>14</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>14</td>\n" +
            "    <td class='changed' " +
                    "style='border:solid; " +
                           "border-width: 1px 1px 1px 1px; " +
                           "border-color: black gray black black'>" +
                  "<pre>    padding: 0 9px 0 9px;</pre>" +
                "</td>\n" +
            "    <td class='changed' style='border:solid black; " +
                                         "border-width: 1px 1px 1px 0;'>" +
                  "<pre>    padding: 0 8px 0 8px;</pre>" +
                "</td>\n" +
            "    <td class='line_number'>15</td>\n" +
            "  </tr>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>15</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 1px 0 0;'>" +
                  "<pre>}</pre>" +
                "</td>\n" +
            "    <td style='border:solid; " +
                           "border-color: gray; " +
                           "border-width: 0 0 0 0;'>" +
                  "<pre>}</pre>" +
                "</td>\n" +
            "    <td class='line_number'>16</td>\n" +
            "  </tr>\n" +
            "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end

    def test_escapes_html
        @builder.push_unchanged '        <h1><%= h(@headline.title) -%></h1>'
        expected_diff_table =
            "<table cellspacing='0'>\n" +
            "  <tr>\n" +
            "    <td class='line_number'>1</td>\n" +
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
            "    <td class='line_number'>1</td>\n" +
            "  </tr>\n" +
            "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end
end