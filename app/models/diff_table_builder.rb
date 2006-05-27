require 'erb'

class DiffTableBuilder

    include ERB::Util

    def initialize
        @mod_groups = []
        @curr_group = 0
        @left_line_to_start = @right_line_to_start = 1
        @last_mod_type = nil
    end

    def render_diff_table
        result  = "<table cellspacing='0'>\n"
        @mod_groups.each do |mg|
            result += mg.render_diff_lines
        end
        result += "</table>"
    end
    
    def start_line(left_line_num, right_line_num=left_line_num)
        @mod_groups << SpacingGroup.instance if @left_line_to_start != 1
        @left_line_to_start = left_line_num
        @right_line_to_start = right_line_num
        @start_new_group = true
    end
    
    { 'addition' => 'add',
      'deletion' => 'del',
      'unchanged' => 'unch'}.each do |k,v|
        eval "def push_#{k}(text); " +
             "get_current_group(:#{v}).push_#{k}(html_escape(text)); " +
             "end"
    end
    
private

    def get_current_group(mod_type)
        if need_a_new_group(mod_type) then
            @mod_groups << create_group(mod_type)
        end
        @last_mod_type = mod_type
                
        return @mod_groups.last
    end
    
    def create_group(mod_type)
        left_line, right_line = curr_lines
        mg = :unch == mod_type ? UnchangedGroup.new(left_line, right_line) :
                                 ModGroup.new(left_line, right_line)
        @left_line_to_start, @right_line_to_start = left_line, right_line
        @start_new_group = false
        return mg
    end

    def curr_lines
        if @start_new_group or @mod_groups.empty? then
          return [@left_line_to_start, @right_line_to_start]
        else
          return [ @left_line_to_start + @mod_groups.last.num_lines_left,
                   @right_line_to_start + @mod_groups.last.num_lines_right ]
        end
    end
    
    CREATE_GROUP_DECISION_TABLE = # current / last
    { :add =>  { :add => false, :del => false, :unch => true },
      :del =>  { :add => true, :del => false, :unch => true },
      :unch => { :add => true, :del => true, :unch => false} }
    
    def need_a_new_group(mod_type)
        if @start_new_group then
            return true
        end
        (@mod_groups.empty?) or
        CREATE_GROUP_DECISION_TABLE[mod_type][@last_mod_type]
    end
    
end

class ModGroup

    def initialize(initial_left_line = 1, initial_right_line = 1)
        @initial_left_line = initial_left_line
        @initial_right_line = initial_right_line
        @deletions = []
        @additions = []
    end
    
    def push_addition(text)
        additions << text
    end
    
    def push_deletion(text)
        deletions << text
    end

    def render_diff_lines
        result = ''
        length = num_lines
        i = 0
        while i < length
            borders_left = cell_border_width(i, :left)
            borders_right = cell_border_width(i, :right)
            
            result += "  <tr>\n"
            result += render_counter(deletions, @initial_left_line, i)
            result += render_left_cell(deletions[i], borders_left)
            result += render_right_cell(additions[i], borders_right)
            result += render_counter(additions, @initial_right_line, i)
            result += "  </tr>\n"

            i += 1
        end
        
        return result
    end
    
    def num_lines_left
        deletions.length
    end

    def num_lines_right
        additions.length
    end

private

    def num_lines
        deletions.length > additions.length ? deletions.length :
                                              additions.length    
    end
    
    def cell_border_width(pos, side)
        borders = 'border-width: '
        
        borders += top_border(pos)
        borders += right_border(pos, side)
        borders += bottom_border(pos, :left == side ? deletions : additions)
        borders += left_border(pos, side)
        
        return borders
    end
    
    def top_border(pos)
        if 0 == pos then
            return '1px '
        else
            return '0 '
        end
    end
    
    def right_border(pos, side)
        if :right == side and 0!=pos and pos >= additions.length then
            return '0 '
        else
            return '1px '
        end
    end
    
    def bottom_border(pos, lines)
        if lines.length == pos+1 or (lines.length == 0 and 0==pos) then
            return '1px '
        else
            return '0 '
        end
    end
    
    def left_border(pos, side)
        if 0!=pos and pos >= additions.length then
            return '1px;'
        elsif !( (:right == side) ^ (0!=pos and pos >= deletions.length) ) then
            return '1px;'
        else
            return '0;'
        end
    end

    def render_left_cell(text, border_width)
        style = "border:solid; " +
                 border_width +
                " border-color: black gray black black"
        return render_cell(text, style)
    end
    
    def render_right_cell(text, border_width)
        style = "border:solid black; " +
                 border_width
        return render_cell(text, style)
    end
    
    def render_cell(text, style)
        if text.nil? then
            return "    <td style='#{style}'>&nbsp;</td>\n"
        else
            return "    <td class='changed' " +
                            "style='#{style}'>" +
                         "<pre>#{text}</pre>" +
                       "</td>\n"
        end
    end
    
    def render_counter(lines, initial_line, pos)
        result = "    <td class='line_number'>"
                     
        if pos < lines.length then
            result += (initial_line + pos).to_s
        else
            result += '&nbsp;'
        end

        result += "</td>\n"
        return result
    end
    
    attr_accessor :additions, :deletions
    
end

class UnchangedGroup

    include ERB::Util

    def initialize(initial_left_line = 1, initial_right_line = 1)
        @lines = []
        @initial_left_line = initial_left_line
        @initial_right_line = initial_right_line
    end

    def push_unchanged(text)
        @lines << text
    end
    
    def num_lines
        @lines.size
    end
    
    alias num_lines_left num_lines
    alias num_lines_right num_lines
    
    def render_diff_lines
        result = ''

        left_count = @initial_left_line
        right_count = @initial_right_line
        @lines.each do |line|
            curr_cell_prefix = "    <td style='border:solid; " +
                                              "border-color: gray; " +
                                              "border-width: 0 "
            curr_cell_suffix =                     " 0 0;'><pre>#{line}</pre>" +
                                   "</td>\n"

            result += "  <tr>\n"
            result += "    <td class='line_number'>#{left_count}</td>\n"
            result += curr_cell_prefix + '1px' + curr_cell_suffix
            result += curr_cell_prefix + '0' + curr_cell_suffix
            result += "    <td class='line_number'>#{right_count}</td>\n"

            result += "  </tr>\n"
            left_count += 1
            right_count += 1
        end

        return result
    end
    
end

class SpacingGroup

    include Singleton

    def render_diff_lines
        cell = "    <td style='border:solid gray; " +
                              "border-width: 1px 0 1px 0;'>&nbsp;</td>\n"

        return "  <tr>\n" + cell + cell + cell + cell + "  </tr>\n"
    end

end