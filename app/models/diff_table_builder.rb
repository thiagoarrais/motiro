class DiffTableBuilder

    def initialize
        @mod_groups = []
        @curr_addition = 0
        @curr_deletion = 0
    end

    def push_addition(text)
        mod = Modification.create_addition(text)
        @mod_groups[@curr_addition] = ModGroup.new if @mod_groups[@curr_addition].nil?
        @mod_groups[@curr_addition].addition = mod
        @curr_addition += 1
    end
    
    def push_deletion(text)
        mod = Modification.create_deletion(text)
        @mod_groups[@curr_deletion] = ModGroup.new if @mod_groups[@curr_deletion].nil?
        @mod_groups[@curr_deletion].deletion = mod
        @curr_deletion += 1
    end
    
    def push_unchanged(text)
        mg = UnchangedLine.new(text)
        @curr_deletion =
            @curr_addition =
                (@curr_deletion > @curr_addition ? @curr_deletion : @curr_addition)
        @mod_groups[@curr_deletion] = mg
        
        @curr_deletion = @curr_addition = @curr_deletion + 1
    end
    
    def render_diff_table
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

class UnchangedLine

    def initialize(text)
        @text = text
    end

    def render_diff_line(line_num)
        result  = "  <tr>\n"
        result += "    <td style='text-align: center'>#{line_num}</td>\n"
        result += "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>#{@text}</pre></td>\n"
        result += "    <td style='border:solid; border-width: 0 0 0 1px;'><pre>#{@text}</pre></td>\n"
        result += "  </tr>\n"
    end

end
