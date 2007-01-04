#  Motiro - A project tracking tool
#  Copyright (C) 2006-2007  Thiago Arrais
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require File.dirname(__FILE__) + '/../test_helper'

require 'stubio'

class StubIOTest < Test::Unit::TestCase

  attr_accessor :stbio
  
  def setup
    @stbio = StubIO.new(initial_value) 
  end
  
  def test_can_read_initial_value
    assert_equal initial_value, stbio.read
  end

  def test_read_initial_value_with_read_and_received_input_with_string
    stbio << received_input
    
    assert_equal initial_value, stbio.read
    assert_equal received_input, stbio.string
  end
  
  def initial_value; 'initial value'; end
  def received_input; 'received input'; end

end