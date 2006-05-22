require File.dirname(__FILE__) + '/../test_helper'

class ChangeTest < Test::Unit::TestCase

    def test_render_diff_with_unset_diff
        change = Change.new(:summary => 'A /directory',
                            :diff => nil)
        
        assert_equal '', change.render_diff
    end
    
    def test_render_diff_with_empty_diff
        change = Change.new(:summary => 'A /directory',
                            :diff => '')
        
        assert_equal '', change.render_diff
    end
    
    def test_render_diff_with_non_empty_diff
        diff_output = "@@ -0,0 +1 @@\n" +
                      "+These are the file_contents"
        change = Change.new(:summary => 'A /a_file.txt',
                            :diff => diff_output)
        
        actual_rendered_output = change.render_diff

        md = actual_rendered_output.match /\A<div id='((\w|\d|-)+)' class='diff-window'><a name='\1' \/><h2>Alterações em a_file.txt<\/h2><pre>\n/
        
        assert_not_nil md
        
        remain = md.post_match
        
        md = remain.match /\n<\/pre><\/div>\Z/
        
        assert_not_nil md
        
        assert_equal diff_output, md.pre_match
    end
    
    def test_render_summary_with_unset_diff
        change = Change.new(:summary => 'A /directory',
                            :diff => nil)
                            
        assert_equal 'A /directory', change.render_summary
    end
    
    def test_render_summary_with_non_empty_diff
        diff_output = "@@ -0,0 +1 @@\n" +
                      "+These are the file_contents"
        change = Change.new(:summary => 'A /a_file.txt',
                            :diff => diff_output)
        
        actual_rendered_output = change.render_summary
        
        md = actual_rendered_output.match /\A<a href='\#((\w|\d|-)+)' onClick="showOnly\('\1'\)">A \/a_file.txt<\/a>\Z/
        
        assert_not_nil md
    end
    
    def test_renders_summary_and_diff_using_the_same_ref
        diff_output = "@@ -0,0 +1 @@\n" +
                      "+These are the file_contents"
        change = Change.new(:summary => 'A /a_file.txt',
                            :diff => diff_output)
                            
        md = change.render_summary.match /\A<a href='\#((\w|\d|-)+)'/
        summary_ref = md[1]
        
        md = change.render_diff.match /\A<div id='((\w|\d|-)+)' class='diff-window'><a name='\1' \/>/
        diff_ref = md[1]
        
        assert_equal summary_ref, diff_ref
    end
    
    def test_usual_qualified_resource_name
        change = Change.new(:summary => 'A /a_file.txt')
        assert_equal '/a_file.txt', change.qualified_resource_name
    end
    
    def test_complex_qualified_resource_name
        change = Change.new(:summary => 'A /subdir/fileC.txt (from /fileA.txt:2)')
        assert_equal '/subdir/fileC.txt', change.qualified_resource_name
    end
    
    def test_complex_resource_name
        change = Change.new(:summary => 'A /subdir/fileC.txt (from /fileA.txt:2)')
        assert_equal 'fileC.txt', change.resource_name
    end
    
    def test_file_not_filled
        change = Change.new(:summary => 'A /subdir/fileC.txt',
                            :resource_kind => 'file',
                            :diff => nil)
        
        assert !change.filled?
    end
    
    def test_file_filled
        change = Change.new(:summary => 'A /subdir/fileC.txt',
                            :resource_kind => 'file',
                            :diff => '+file change')
        
        assert change.filled?
    end

    def test_directory_always_filled
        change = Change.new(:summary => 'A /subdir',
                            :resource_kind => 'dir',
                            :diff => nil)
        
        assert change.filled?
    end

    def test_unknown_always_not_filled
        change = Change.new(:summary => 'A /subdir/fileC.txt',
                            :resource_kind => nil,
                            :diff => '+file change')
        
        assert ! change.filled?
    end
    
end
