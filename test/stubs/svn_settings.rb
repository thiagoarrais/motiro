class StubConnectionSettingsProvider
    
    def initialize(params)
        params[:repo] = 'http://svn.fake.domain.org/fake_repo' if params[:repo].nil?
        params[:package_size] = 5 if params[:package_size].nil?
        params[:update_interval] = 10 if params[:package_size].nil?
        
        @confs = params
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
end