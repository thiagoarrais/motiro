require File.dirname(__FILE__) + '/../test_helper'

require 'stringio'

require 'core/settings'

class SettingsProviderTest < Test::Unit::TestCase

  def setup
    @expected_file_name = File.expand_path(File.dirname(__FILE__) +
                                           '../../../config/motiro.yml')
    @opener = FlexMock.new 
        
    @opener.should_receive(:open).with(@expected_file_name).
      once.
      returns( StringIO.new( "package_size: 8\n" +
                             "update_interval: 10\n" +
                             "darcs:\n" +
                             "  repo: http://eclipsefp.sf.net/repos/trunk\n"))

    @provider = SubversionSettingsProvider.new(@opener)
  end

  def teardown
    @opener.mock_verify
  end

  def test_active_reporters
    assert_equal ['darcs'], @provider.active_reporter_ids
  end

  def test_fetches_package_size
    assert_equal 8, @provider.package_size
  end
    
  def test_fectches_update_interval
    assert_equal 10, @provider.update_interval
  end
    
  def test_dynamically_fetches_parameters
    assert_equal 8, @provider.package_size
    @opener.mock_verify
        
    @opener.should_receive(:open).with(@expected_file_name).
      returns do
        StringIO.new("package_size: 5\n" +
                     "svn:\n" +
                     "  repo: http://svn.berlios.de/svnroot/repos/motiro\n")
      end 
        
    assert_equal 5, @provider.package_size
    assert_equal ['svn'], @provider.active_reporter_ids
  end

end