require File.dirname(__FILE__) + '/../test_helper'
require 'report_controller'

require 'stubs/svn_settings'

class Class
    include Test::Unit::Assertions
end

# Re-raise errors caught by the controller.
class ReportController; def rescue_action(e) raise e end; end

class ReportControllerTest < Test::Unit::TestCase

    fixtures :headlines

    @@log = ''

    def self.append_to_log(txt)
        @@log << txt
    end

    def setup
      @controller = ReportController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
    
    def test_fetches_headlines_from_cache
      get :show, {:format => 'show'}
      assert_response :success
      assert_not_nil assigns(:headlines)
      assert_equal 2, assigns(:headlines).size
    end
  
    def test_reads_package_size
        settings = StubConnectionSettingsProvider.new(
                       :package_size => 6)

        def Headline.latest(num)
            assert_equal 6, num
            ReportControllerTest.append_to_log 'latest'
        end

        controller = ReportController.new(settings)
        controller.subversion
        
        assert_equal 'latest', @@log
    end

  #TODO what happens if there are no cached headlines?
  #TODO more headlines registered than the package size
  
end
