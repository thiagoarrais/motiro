require 'erb'

class DiffTableBuilder

    include ERB::Util

    def initialize
        @mod_groups = []
        @curr_group = 0
        @last_mod_type = nil
    end

    def render_diff_table
        result  = "<table cellspacing='0'>\n"
        counter = Counter.new
        @mod_groups.each do |mg|
            result += mg.render_diff_lines(counter)
        end
        result += "</table>"
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
            mg = :unch == mod_type ? UnchangedGroup.new : ModGroup.new
            @mod_groups << mg
        end
        @last_mod_type = mod_type
                
        return @mod_groups.last
    end
    
    
    CREATE_GROUP_DECISION_TABLE = # current / last
    { :add =>  { :add => false, :del => false, :unch => true },
      :del =>  { :add => true, :del => false, :unch => true },
      :unch => { :add => true, :del => true, :unch => false} }
    
    def need_a_new_group(mod_type)
        (@mod_groups.empty?) or
        CREATE_GROUP_DECISION_TABLE[mod_type][@last_mod_type]
    end
    
end

class ModGroup

    def initialize
        @deletions = []
        @additions = []
    end
    
    def push_addition(text)
        additions << text
    end
    
    def push_deletion(text)
        deletions << text
    end

    def render_diff_lines(count)
        result = ''
        length = deletions.length > additions.length ?
            deletions.length : additions.length
        i = 0
        while i < length
            count.incc
            borders_left = cell_border_width(i, :left)
            borders_right = cell_border_width(i, :right)
            
            result += "  <tr>\n"
            result += "    <td style='text-align: center; " +
                                     "border:solid gray; " +
                                     "border-width: 0 1px 0 0;'>" +
                            "#{count.value}" +
                          "</td>\n"
            result += render_left_cell(deletions[i], borders_left)
            result += render_right_cell(additions[i], borders_right)
            result += "  </tr>\n"
            i += 1
        end
        
        return result
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

    def initialize
        @lines = []
    end

    def push_unchanged(text)
        @lines << text
    end
    
    def render_diff_lines(count)
        result = ''

        @lines.each do |line|
            count.incc
            curr_cell_prefix = "    <td style='border:solid; " +
                               "border-color: gray; " +
                               "border-width: 0 "
            curr_cell_suffix = " 0 0;'><pre>#{line}</pre>" +
                                   "</td>\n"

            result += "  <tr>\n"
            result += "    <td style='text-align: center; " +
                                     "border:solid gray; " +
                                     "border-width: 0 1px 0 0;'>" +
                             count.value.to_s +
                          "</td>\n"
            result += curr_cell_prefix + '1px' + curr_cell_suffix
            result += curr_cell_prefix + '0' + curr_cell_suffix
            result += "  </tr>\n"
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
