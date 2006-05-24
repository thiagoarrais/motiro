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
    
    %w{addition deletion unchanged}.each do |w|
        eval "def push_#{w}(text); " +
             "get_current_group(:#{w}).push_#{w}(html_escape(text)); " +
             "end"
    end
    
private

    def get_current_group(mod_type)
        if need_a_new_group(mod_type) then
            mg = :unchanged == mod_type ? UnchangedGroup.new : ModGroup.new
            @mod_groups << mg
        end
        @last_mod_type = mod_type
                
        return @mod_groups.last
    end
    
    def need_a_new_group(mod_type)
        (@mod_groups.last.nil?) or
        (:deletion == mod_type and :deletion != @last_mod_type) or
        (:unchanged == mod_type and :unchanged != @last_mod_type) or
        (:unchanged != mod_type and :unchanged == @last_mod_type)
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
            borders_left, borders_right = border_widths_for(i)
            
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

    def border_widths_for(pos)
        borders_left = borders_right = 'border-width: '
        if 0 == pos then
            borders_left += '1px '
            borders_right += '1px '
        else
            borders_left += '0 '
            borders_right += '0 '
        end
        borders_left += '1px '
        if 0!=pos and pos >= additions.length then
            borders_right += '0 '
        else
            borders_right += '1px '
        end
        if deletions.length == pos+1 or (deletions.length == 0 and 0==pos) then
            borders_left += '1px '
        else
            borders_left += '0 '
        end
        if additions.length == pos+1 or (additions.length == 0 and 0==pos) then
            borders_right += '1px '
        else
            borders_right += '0 '
        end
        if 0!=pos and pos >= deletions.length then
            borders_left += '0;'
            borders_right += '1px;'
        elsif 0!=pos and pos >= additions.length then
            borders_left += '1px;'
            borders_right += '1px;'
        else
            borders_left += '1px;'
            borders_right += '0;'
        end
        
        return borders_left, borders_right
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
