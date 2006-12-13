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
        result  = "<table class='diff 'cellspacing='0'>\n"
        @mod_groups.each do |mg|
            result += mg.render_diff_lines
        end
        result += "</table>"
    end
    
    def start_line(left_line_num, right_line_num=left_line_num)
        @mod_groups << SpacingGroup.instance if @left_line_to_start != 1 || @right_line_to_start != 1
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

class Group

    def render_diff_lines
        result = ''
        0.upto(num_lines - 1) do |i|
            
            result += "  <tr>\n"
            result += render_counter(:left, i)
            result += render_left_cell(i)
            result += render_right_cell(i)
            result += render_counter(:right, i)
            result += "  </tr>\n"
        end
        
        return result
    end
    
protected

    attr_reader :initial_left_line, :initial_right_line

    def initialize(initial_left_line = 1, initial_right_line = 1)
        @initial_left_line = initial_left_line
        @initial_right_line = initial_right_line
    end

    def render_cell_contents(text)
        return "<pre>#{text}</pre>" unless text.nil? || 0 == text.length
        return '&nbsp;'
    end
    
    def render_counter(side, pos)
        num_lines, initial_line = num_lines_left, initial_left_line
        if :right == side then
            num_lines, initial_line = num_lines_right, initial_right_line
        end
        
        result = "    <td class='line_number'>"
                     
        if pos < num_lines then
            result += (initial_line + pos).to_s
        else
            result += '&nbsp;'
        end

        return result + "</td>\n"
    end

    def render_left_cell(pos)
        style = cell_border_width(pos, :left)
        return render_cell(left_lines[pos], style, :left)
    end
    
    def render_right_cell(pos)
        style = cell_border_width(pos, :right)
        return render_cell(right_lines[pos], style, :right)
    end
    
    def render_cell(text, style, side)
        clazz = class_for(text)
        cell_contents = render_cell_contents(text)
        return "    <td class='#{side.to_s}#{clazz}' style='#{style}'>" +
                     cell_contents +
                   "</td>\n"
    end

end

class ModGroup < Group

    def initialize(initial_left_line = 1, initial_right_line = 1)
        super(initial_left_line, initial_right_line)
        @deletions = []
        @additions = []
    end
    
    def push_addition(text)
        additions << text
    end
    
    def push_deletion(text)
        deletions << text
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

    
    def class_for(text)
        return ' changed' unless text.nil?
        return ''
    end
    
    attr_accessor :additions, :deletions
    alias left_lines deletions
    alias right_lines additions
    
end

class UnchangedGroup < Group

    include ERB::Util

    def initialize(initial_left_line = 1, initial_right_line = 1)
        super(initial_left_line, initial_right_line)
        @lines = []
    end

    def push_unchanged(text)
        @lines << text
    end
    
    def num_lines
        @lines.size
    end
    
    alias num_lines_left num_lines
    alias num_lines_right num_lines
    
private

    def cell_border_width(pos, side)
        return 'border-width: 0 1px 0 0;' if :left == side
        return 'border-width: 0 0 0 0;'
    end

    def class_for(text)
        return ''
    end
    
    attr_accessor :lines
    alias left_lines lines
    alias right_lines lines

end

class SpacingGroup

    include Singleton

    def render_diff_lines
        cell = "    <td style='border:solid gray; " +
                              "border-width: 1px 0 1px 0;'>&nbsp;</td>\n"

        return "  <tr>\n" + cell + cell + cell + cell + "  </tr>\n"
    end

end