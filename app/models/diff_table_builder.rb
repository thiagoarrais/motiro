class DiffTableBuilder

    def initialize
        @mod_groups = []
        @current_group = ModGroup.new
    end

    def push_addition(text)
        mod = Modification.create_addition(text)
        if @current_group.addition.nil? then
            @current_group.addition = mod
        else
            @mod_groups << @current_group
            @current_group = ModGroup.new
            @current_group.addition = mod
        end
    end
    
    def push_deletion(text)
        mod = Modification.create_deletion(text)
        if @current_group.deletion.nil? then
            @current_group.deletion = mod
        else
            @mod_groups << @current_group
            @current_group = ModGroup.new
            @current_group.deletion = mod
        end
    end
    
    def render_diff_table
        @mod_groups << @current_group
        result  = "<table cellspacing='0'>\n"
        i = 0
        @mod_groups.each do |mg|
            i += 1
            result += mg.render_diff_line(i)
        end
        result += "</table>"
    end

end

class Modification
    
    def self.create_addition(text)
        self.new('+', text)
    end
    
    def self.create_deletion(text)
        self.new('-', text)
    end
    
    def initialize(type, text)
        @type, @text = type, text
    end
    
    def render_diff_cell
        clazz = @type == '-' ? 'removed' : 'added'
        "    <td class='#{clazz}' style='border:solid; border-width: 0 0 0 1px;'><pre>#{@text}</pre></td>\n"
    end

end

class ModGroup

    attr_accessor :deletion, :addition
    
    def render_diff_line(line_num)
        result  = "  <tr>\n"
        result += "    <td style='text-align: center'>#{line_num}</td>\n"
        result += render_diff_cell(deletion)
        result += render_diff_cell(addition)
        result += "  </tr>\n"
    end
    
    def render_diff_cell(mod)
        if mod.nil? then
            return "    <td />\n"
        else
            return mod.render_diff_cell
        end
    end

end
