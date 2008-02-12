#  Motiro - A project tracking tool
#  Copyright (C) 2006-2008  Thiago Arrais
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

require 'reporters/subversion_reporter'

class SubversionReporterInteractionTest < Test::Unit::TestCase

  def test_asks_for_specific_revision
    FlexMock.use do |conn|
      conn.should_receive(:log).with(:only => '113').returns('').once
      SubversionReporter.new(conn).headline('r113')
    end
  end
  
  def test_asks_for_non_cached_revisions_only
    FlexMock.use do |conn|
      conn.should_receive(:log).with(:history_from => 'r206').returns('').once
      SubversionReporter.new(conn).latest_headlines('r206')
    end
  end

end