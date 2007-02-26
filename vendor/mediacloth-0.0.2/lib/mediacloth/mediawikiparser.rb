#
# DO NOT MODIFY!!!!
# This file is automatically generated by racc 1.4.5
# from racc grammer file "mediawikiparser.y".
#

require 'racc/parser'


require 'mediacloth/mediawikiast'


class MediaWikiParser < Racc::Parser

module_eval <<'..end mediawikiparser.y modeval..id823eb1450e', 'mediawikiparser.y', 186

attr_accessor :lexer

def initialize
    @nodes = []
    super
end

#Tokenizes input string and parses it.
def parse(input)
    @yydebug=true
    lexer.tokenize(input)
    do_parse
    return @nodes.last
end

#Asks the lexer to return the next token.
def next_token
    return @lexer.lex
end
..end mediawikiparser.y modeval..id823eb1450e

##### racc 1.4.5 generates ###

racc_reduce_table = [
 0, 0, :racc_error,
 1, 27, :_reduce_1,
 1, 29, :_reduce_2,
 1, 29, :_reduce_3,
 1, 29, :_reduce_4,
 1, 29, :_reduce_5,
 1, 29, :_reduce_6,
 3, 29, :_reduce_7,
 0, 35, :_reduce_8,
 1, 35, :_reduce_9,
 1, 28, :_reduce_10,
 2, 28, :_reduce_11,
 1, 30, :_reduce_12,
 1, 30, :_reduce_13,
 3, 36, :_reduce_14,
 3, 36, :_reduce_15,
 1, 36, :_reduce_16,
 1, 36, :_reduce_17,
 1, 36, :_reduce_18,
 1, 36, :_reduce_19,
 1, 36, :_reduce_20,
 3, 37, :_reduce_21,
 3, 37, :_reduce_22,
 4, 31, :_reduce_23,
 4, 32, :_reduce_24,
 0, 40, :_reduce_25,
 3, 39, :_reduce_26,
 0, 39, :_reduce_27,
 3, 38, :_reduce_28,
 1, 33, :_reduce_29,
 3, 34, :_reduce_30 ]

racc_reduce_n = 31

racc_shift_n = 53

racc_action_table = [
     6,    36,    10,   -27,    16,    35,    20,    26,    23,    41,
     3,     5,     8,    11,    13,    15,    18,     6,    32,    10,
     1,    16,     7,    20,    31,    23,    43,     3,     5,     8,
    11,    13,    15,    18,    44,   -27,    50,     1,     6,     7,
    10,    46,    16,    47,    20,    48,    23,    26,     3,     5,
     8,    11,    13,    15,    18,     6,    26,    10,     1,    16,
     7,    20,    51,    23,   -25,     3,     5,     8,    11,    13,
    15,    18,     6,   nil,    10,     1,    16,     7,    20,   nil,
    23,   nil,     3,     5,     8,    11,    13,    15,    18,   nil,
   nil,   nil,     1,     6,     7,    10,    42,    16,   nil,    20,
   nil,    23,   nil,     3,     5,     8,    11,    13,    15,    18,
     6,   nil,    10,     1,    16,     7,    20,   nil,    23,   nil,
     3,     5,     8,    11,    13,    15,    18,     6,   nil,    10,
     1,    16,     7,    20,   nil,    23,   nil,     3,     5,     8,
    11,    13,    15,    18,     6,   nil,    10,     1,    16,     7,
    20,   nil,    23,   nil,     3,     5,     8,    11,    13,    15,
    18,     6,    40,    10,     1,    16,     7,    20,   nil,    23,
   nil,     3,     5,     8,    11,    13,    15,    18,   nil,   nil,
   nil,     1,   nil,     7 ]

racc_action_check = [
     0,    23,     0,    25,     0,    20,     0,    18,     0,    28,
     0,     0,     0,     0,     0,     0,     0,    39,    16,    39,
     0,    39,     0,    39,    14,    39,    31,    39,    39,    39,
    39,    39,    39,    39,    32,    34,    39,    39,     6,    39,
     6,    35,     6,    36,     6,    37,     6,    38,     6,     6,
     6,     6,     6,     6,     6,     7,     1,     7,     6,     7,
     6,     7,    45,     7,    49,     7,     7,     7,     7,     7,
     7,     7,    10,   nil,    10,     7,    10,     7,    10,   nil,
    10,   nil,    10,    10,    10,    10,    10,    10,    10,   nil,
   nil,   nil,    10,    30,    10,    30,    30,    30,   nil,    30,
   nil,    30,   nil,    30,    30,    30,    30,    30,    30,    30,
    29,   nil,    29,    30,    29,    30,    29,   nil,    29,   nil,
    29,    29,    29,    29,    29,    29,    29,    17,   nil,    17,
    29,    17,    29,    17,   nil,    17,   nil,    17,    17,    17,
    17,    17,    17,    17,    26,   nil,    26,    17,    26,    17,
    26,   nil,    26,   nil,    26,    26,    26,    26,    26,    26,
    26,    27,    27,    27,    26,    27,    26,    27,   nil,    27,
   nil,    27,    27,    27,    27,    27,    27,    27,   nil,   nil,
   nil,    27,   nil,    27 ]

racc_action_pointer = [
    -2,    36,   nil,   nil,   nil,   nil,    36,    53,   nil,   nil,
    70,   nil,   nil,   nil,    24,   nil,     6,   125,   -13,   nil,
    -7,   nil,   nil,   -11,   nil,   -20,   142,   159,   -16,   108,
    91,    26,    27,   nil,    16,    32,    32,    22,    27,    15,
   nil,   nil,   nil,   nil,   nil,    43,   nil,   nil,   nil,    44,
   nil,   nil,   nil ]

racc_action_default = [
   -31,   -31,    -5,   -16,    -6,   -29,   -31,    -8,   -17,   -12,
   -31,   -19,   -13,   -18,   -31,   -20,   -31,    -1,   -31,   -10,
   -31,    -2,    -3,   -31,    -4,   -25,   -31,   -31,   -31,    -9,
   -31,   -31,   -31,   -11,   -25,   -31,   -31,   -31,   -31,   -31,
   -21,    -7,   -22,    53,   -14,   -31,   -15,   -30,   -24,   -27,
   -28,   -23,   -26 ]

racc_goto_table = [
    25,    17,    33,    28,    37,    14,   nil,    27,    29,   nil,
   nil,    30,    33,    45,    33,    33,   nil,    34,   nil,   nil,
   nil,   nil,   nil,   nil,    33,   nil,   nil,    39,    52,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,    49 ]

racc_goto_check = [
    12,     2,     3,     9,    13,     1,   nil,     2,     2,   nil,
   nil,     2,     3,    13,     3,     3,   nil,    12,   nil,   nil,
   nil,   nil,   nil,   nil,     3,   nil,   nil,     2,    13,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,    12 ]

racc_goto_pointer = [
   nil,     5,     1,   -15,   nil,   nil,   nil,   nil,   nil,    -4,
   nil,   nil,    -1,   -21,   nil ]

racc_goto_default = [
   nil,   nil,   nil,    19,    21,    22,    24,     2,     4,   nil,
     9,    12,   nil,   nil,    38 ]

racc_token_table = {
 false => 0,
 Object.new => 1,
 :BOLDSTART => 2,
 :BOLDEND => 3,
 :ITALICSTART => 4,
 :ITALICEND => 5,
 :LINKSTART => 6,
 :LINKEND => 7,
 :INTLINKSTART => 8,
 :INTLINKEND => 9,
 :SECTION_START => 10,
 :SECTION_END => 11,
 :TEXT => 12,
 :PRE => 13,
 :HLINE => 14,
 :SIGNATURE_NAME => 15,
 :SIGNATURE_DATE => 16,
 :SIGNATURE_FULL => 17,
 :UL_START => 18,
 :UL_END => 19,
 :LI_START => 20,
 :LI_END => 21,
 :OL_START => 22,
 :OL_END => 23,
 :PARA_START => 24,
 :PARA_END => 25 }

racc_use_result_var = true

racc_nt_base = 26

Racc_arg = [
 racc_action_table,
 racc_action_check,
 racc_action_default,
 racc_action_pointer,
 racc_goto_table,
 racc_goto_check,
 racc_goto_default,
 racc_goto_pointer,
 racc_nt_base,
 racc_reduce_table,
 racc_token_table,
 racc_shift_n,
 racc_reduce_n,
 racc_use_result_var ]

Racc_token_to_s_table = [
'$end',
'error',
'BOLDSTART',
'BOLDEND',
'ITALICSTART',
'ITALICEND',
'LINKSTART',
'LINKEND',
'INTLINKSTART',
'INTLINKEND',
'SECTION_START',
'SECTION_END',
'TEXT',
'PRE',
'HLINE',
'SIGNATURE_NAME',
'SIGNATURE_DATE',
'SIGNATURE_FULL',
'UL_START',
'UL_END',
'LI_START',
'LI_END',
'OL_START',
'OL_END',
'PARA_START',
'PARA_END',
'$start',
'wiki',
'repeated_contents',
'contents',
'text',
'bulleted_list',
'numbered_list',
'preformatted',
'section',
'para_contents',
'element',
'formatted_element',
'list_item',
'list_contents',
'@1']

Racc_debug_parser = false

##### racc system variables end #####

 # reduce 0 omitted

module_eval <<'.,.,', 'mediawikiparser.y', 26
  def _reduce_1( val, _values, result )
            @nodes.push WikiAST.new
            #@nodes.last.children.insert(0, val[0])
            #puts val[0]
            @nodes.last.children += val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 33
  def _reduce_2( val, _values, result )
            result = val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 37
  def _reduce_3( val, _values, result )
            result = val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 41
  def _reduce_4( val, _values, result )
            result = val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 47
  def _reduce_5( val, _values, result )
            p = PreformattedAST.new
            p.contents = val[0]
            result = p
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 54
  def _reduce_6( val, _values, result )
            s = SectionAST.new
            s.contents = val[0][0]
            s.level = val[0][1]
            result = s
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 62
  def _reduce_7( val, _values, result )
            if val[1]
                p = ParagraphAST.new
                p.children = val[1]
                result = p
            end
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 69
  def _reduce_8( val, _values, result )
            result = nil
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 73
  def _reduce_9( val, _values, result )
            result = val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 79
  def _reduce_10( val, _values, result )
            result = []
            result << val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 85
  def _reduce_11( val, _values, result )
            result = []
            result += val[0]
            result << val[1]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 94
  def _reduce_12( val, _values, result )
            p = TextAST.new
            p.formatting = val[0][0]
            p.contents = val[0][1]
            result = p
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 98
  def _reduce_13( val, _values, result )
            result = val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 101
  def _reduce_14( val, _values, result )
 return [:Link, val[1]]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 103
  def _reduce_15( val, _values, result )
 return [:InternalLink, val[1]]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 105
  def _reduce_16( val, _values, result )
 return [:None, val[0]]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 107
  def _reduce_17( val, _values, result )
 return [:HLine, val[0]]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 109
  def _reduce_18( val, _values, result )
 return [:SignatureDate, val[0]]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 111
  def _reduce_19( val, _values, result )
 return [:SignatureName, val[0]]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 113
  def _reduce_20( val, _values, result )
 return [:SignatureFull, val[0]]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 123
  def _reduce_21( val, _values, result )
            p = FormattedAST.new
            p.formatting = :Bold
            p.children += val[1]
            result = p
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 130
  def _reduce_22( val, _values, result )
            p = FormattedAST.new
            p.formatting = :Italic
            p.children += val[1]
            result = p
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 140
  def _reduce_23( val, _values, result )
            list = ListAST.new
            list.list_type = :Bulleted
            list.children << val[1]
            list.children += val[2]
            result = list
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 150
  def _reduce_24( val, _values, result )
            list = ListAST.new
            list.list_type = :Numbered
            list.children << val[1]
            list.children += val[2]
            result = list
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 153
  def _reduce_25( val, _values, result )
 result = []
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 159
  def _reduce_26( val, _values, result )
            result << val[1]
            result += val[2]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 160
  def _reduce_27( val, _values, result )
 result = []
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 169
  def _reduce_28( val, _values, result )
            li = ListItemAST.new
            li.children += val[1]
            result = li
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 172
  def _reduce_29( val, _values, result )
 result = val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'mediawikiparser.y', 176
  def _reduce_30( val, _values, result )
 result = [val[1], val[0].length]
   result
  end
.,.,

 def _reduce_none( val, _values, result )
  result
 end

end   # class MediaWikiParser