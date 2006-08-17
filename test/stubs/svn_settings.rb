class StubConnectionSettingsProvider
    
    def initialize(params=Hash.new)
        @confs = { :repo => 'http://svn.fake.domain.org/fake_repo',
                   :package_size => 5,
                   :update_interval => 10,
                   :active_reporter_ids => ['subversion'] }
        @confs.update(params)
    end
    
    def repo_url
        @confs[:repo]
    end
    
    def method_missing(method_id)
      @confs[method_id]
    end
    
end