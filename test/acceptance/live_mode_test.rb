require 'configuration'
require 'local_svn'

module LiveModeTestCase

  def setup
    super
    @repo = create_repository
    @config = Configuration.new(repo_type)
    @config.repo = @repo.url
    @config.go_live
    do_setup
  end

  def create_repository
    LocalSubversionRepository.new
  end
  
  def repo_type
    'subversion'
  end

  def do_setup; end
    
  def teardown
    super
    @repo.destroy
    @config.revert
    do_teardown
  end

  def do_teardown; end

end