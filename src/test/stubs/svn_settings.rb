class StubConnectionSettingsProvider
    
    def initialize(repo_url)
        @repo_url = repo_url
    end
    
    def getRepoURL
        @repo_url
    end
    
end