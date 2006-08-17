require File.dirname(__FILE__) + '/../test_helper'

require 'stringio'

require 'core/settings'

class SettingsProviderTest < Test::Unit::TestCase

  def test_active_reporters
    FlexMock.use do |filesystem|
      filesystem.should_receive(:open).with_any_args.
        returns(StringIO.new( "package_size: 8\n" +
                              "update_interval: 10\n" +
                              "darcs:\n" +
                              "  repo: http://eclipsefp.sf.net/repos/trunk\n"))
      
      settings = SettingsProvider.new(filesystem)
      assert_equal ['darcs'], settings.active_reporter_ids
    end
  end

end