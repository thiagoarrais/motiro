require 'erb'

class DiffTableBuilder

    include ERB::Util

    def initialize
        @mod_groups = []
        @curr_group = 0
        @line_to_start = 1
        @last_mod_type = nil
    end

    def render_diff_table
        result  = "<table cellspacing='0'>\n"
        @mod_groups.each do |mg|
            result += mg.render_diff_lines
        end
        result += "</table>"
    end
    
    def start_line(line_num)
        @line_to_start = line_num
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
        mg = :unch == mod_type ? UnchangedGroup.new(curr_line) :
                                 ModGroup.new(curr_line)
        @line_to_start = curr_line
        @start_new_group = false
        return mg
    end

    def curr_line
        return @line_to_start if @start_new_group or @mod_groups.empty?
        return @mod_groups.last.num_lines + @line_to_start
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

    def initialize(initial_line = 1)
        @initial_line = initial_line
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
            result += "    <td style='text-align: center; " +
                                     "border:solid gray; " +
                                     "border-width: 0 1px 0 0;'>" +
                             (@initial_line + i).to_s +
                          "</td>\n"
            result += render_left_cell(deletions[i], borders_left)
            result += render_right_cell(additions[i], borders_right)
            result += "  </tr>\n"

            i += 1
        end
        
        return result
    end
    
    def num_lines
        deletions.length > additions.length ? deletions.length :
                                              additions.length    
    end
    
private

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
    
    attr_accessor :additions, :deletions

end

class UnchangedGroup

    include ERB::Util

    def initialize(initial_line = 1)
        @lines = []
        @initial_line = initial_line
    end

    def push_unchanged(text)
        @lines << text
    end
    
    def num_lines
        @lines.size
    end
    
    def render_diff_lines
        result = ''

        count = @initial_line
        @lines.each do |line|
            curr_cell_prefix = "    <td style='border:solid; " +
                               "border-color: gray; " +
                               "border-width: 0 "
            curr_cell_suffix = " 0 0;'><pre>#{line}</pre>" +
                                   "</td>\n"

            result += "  <tr>\n"
            result += "    <td style='text-align: center; " +
                                     "border:solid gray; " +
                                     "border-width: 0 1px 0 0;'>" +
                             count.to_s +
                          "</td>\n"
            result += curr_cell_prefix + '1px' + curr_cell_suffix
            result += curr_cell_prefix + '0' + curr_cell_suffix
            result += "  </tr>\n"
            count += 1
        end

        return result
    end
    
end

class Counter

    attr_reader :value

    def initialize
        @value = 0
    end

    def incc
        @value += 1    
    end
    
end
