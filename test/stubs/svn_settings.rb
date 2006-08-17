class StubConnectionSettingsProvider
    
    def initialize(params=Hash.new)
        @confs = { :repo => 'http://svn.fake.domain.org/fake_repo',
                   :package_size => 5,
                   :update_interval => 10,
                   :active_reporter_ids => ['subversion'] }
        @confs.update(params)
    end
    
    def getRepoURL
        @confs[:repo]
    end
    
    def getPackageSize
        @confs[:package_size]
    end
    
    def getUpdateInterval
        @confs[:update_interval]
    end
    
    def active_reporter_ids
       @confs[:active_reporter_ids]
    end
end