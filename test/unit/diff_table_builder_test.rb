require File.dirname(__FILE__) + '/../test_helper'
require 'diff_table_builder'

class DiffTableBuilderTest < Test::Unit::TestCase

    def setup
        @builder = DiffTableBuilder.new
    end

    def test_renders_addition_only
        @builder.push_addition 'I have added this'
        
        expected_diff_table = "<table cellspacing='0'>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>1</td>\n" +
                              "    <td />\n" +
                              "    <td class='added' style='border:solid; border-width: 0 0 0 1px;'><pre>I have added this</pre></td>\n" +
                              "  </tr>\n" +
                              "</table>"
        
        assert_equal expected_diff_table, @builder.render_diff_table
    end

    def test_matches_alterning_addition_and_deletion
        @builder.push_deletion 'I have removed this'
        @builder.push_addition 'I have added this'
        
        expected_diff_table = "<table cellspacing='0'>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>1</td>\n" +
                              "    <td class='removed' style='border:solid; border-width: 0 0 0 1px;'><pre>I have removed this</pre></td>\n" +
                              "    <td class='added' style='border:solid; border-width: 0 0 0 1px;'><pre>I have added this</pre></td>\n" +
                              "  </tr>\n" +
                              "</table>"
        
        assert_equal expected_diff_table, @builder.render_diff_table
    end
    
    def test_multiline_modification
        @builder.push_deletion 'This is the first old line'
        @builder.push_deletion 'This is the second old line'
        @builder.push_addition 'This is the first new line'
        @builder.push_addition 'This is the second new line'

        expected_diff_table = "<table cellspacing='0'>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>1</td>\n" +
                              "    <td class='removed' style='border:solid; border-width: 0 0 0 1px;'><pre>This is the first old line</pre></td>\n" +
                              "    <td class='added' style='border:solid; border-width: 0 0 0 1px;'><pre>This is the first new line</pre></td>\n" +
                              "  </tr>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>2</td>\n" +
                              "    <td class='removed' style='border:solid; border-width: 0 0 0 1px;'><pre>This is the second old line</pre></td>\n" +
                              "    <td class='added' style='border:solid; border-width: 0 0 0 1px;'><pre>This is the second new line</pre></td>\n" +
                              "  </tr>\n" +
                              "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end
    
    def test_more_adds_than_deletes
        @builder.push_deletion 'This is the first old line'
        @builder.push_addition 'This is the first new line'
        @builder.push_addition 'This is the second new line'

        expected_diff_table = "<table cellspacing='0'>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>1</td>\n" +
                              "    <td class='removed' style='border:solid; border-width: 0 0 0 1px;'><pre>This is the first old line</pre></td>\n" +
                              "    <td class='added' style='border:solid; border-width: 0 0 0 1px;'><pre>This is the first new line</pre></td>\n" +
                              "  </tr>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>2</td>\n" +
                              "    <td />\n" +
                              "    <td class='added' style='border:solid; border-width: 0 0 0 1px;'><pre>This is the second new line</pre></td>\n" +
                              "  </tr>\n" +
                              "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end
    
    def test_some_code_kept
        @builder.push_unchanged '}'
        @builder.push_unchanged ''
        @builder.push_unchanged 'div.channel-title {'
        @builder.push_deletion  '    font: normal 8pt Verdana,sans-serif;'
        @builder.push_addition  '    font: bold 10pt Verdana,sans-serif;'
        @builder.push_unchanged '    margin:0 0 0 0;'
        @builder.push_deletion  '    padding: 2px 2px 0 8px;'
        @builder.push_addition  '    padding: 2px 2px 1px 8px;'
        @builder.push_unchanged '    text-align:left;'
        @builder.push_unchanged '    color: #000'
        @builder.push_unchanged '}'
        
        expected_diff_table = "<table cellspacing='0'>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>1</td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>}</pre></td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>}</pre></td>\n" +
                              "  </tr>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>2</td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre></pre></td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre></pre></td>\n" +
                              "  </tr>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>3</td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>div.channel-title {</pre></td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>div.channel-title {</pre></td>\n" +
                              "  </tr>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>4</td>\n" +
                              "    <td class='removed' style='border:solid; border-width: 0 0 0 1px;'><pre>    font: normal 8pt Verdana,sans-serif;</pre></td>\n" +
                              "    <td class='added' style='border:solid; border-width: 0 0 0 1px;'><pre>    font: bold 10pt Verdana,sans-serif;</pre></td>\n" +
                              "  </tr>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>5</td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>    margin:0 0 0 0;</pre></td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>    margin:0 0 0 0;</pre></td>\n" +
                              "  </tr>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>6</td>\n" +
                              "    <td class='removed' style='border:solid; border-width: 0 0 0 1px;'><pre>    padding: 2px 2px 0 8px;</pre></td>\n" +
                              "    <td class='added' style='border:solid; border-width: 0 0 0 1px;'><pre>    padding: 2px 2px 1px 8px;</pre></td>\n" +
                              "  </tr>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>7</td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>    text-align:left;</pre></td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>    text-align:left;</pre></td>\n" +
                              "  </tr>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>8</td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>    color: #000</pre></td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>    color: #000</pre></td>\n" +
                              "  </tr>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>9</td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>}</pre></td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>}</pre></td>\n" +
                              "  </tr>\n" +
                              "</table>"
        
        assert_equal expected_diff_table, @builder.render_diff_table
    end
    
    def test_escapes_html
        @builder.push_unchanged '        <h1><%= h(@headline.title) -%></h1>'
        expected_diff_table = "<table cellspacing='0'>\n" +
                              "  <tr>\n" +
                              "    <td style='text-align: center'>1</td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>        &lt;h1&gt;&lt;%= h(@headline.title) -%&gt;&lt;/h1&gt;</pre></td>\n" +
                              "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>        &lt;h1&gt;&lt;%= h(@headline.title) -%&gt;&lt;/h1&gt;</pre></td>\n" +
                              "  </tr>\n" +
                              "</table>"

        assert_equal expected_diff_table, @builder.render_diff_table
    end
end