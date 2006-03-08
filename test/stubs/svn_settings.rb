class StubConnectionSettingsProvider
    
    def initialize(params)
        params[:repo] = 'http://svn.fake.domain.org/fake_repo' if params[:repo].nil?
        params[:package_size] = 5 if params[:package_size].nil?

        @repo_url = params[:repo]
        @package_size = params[:package_size]
    end
    
    def getRepoURL
        @repo_url
    end
    
    def getPackageSize
        @package_size
    end
    
end