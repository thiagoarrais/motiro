class SubversionConnection
    
    #TODO parametize the repo location
    #TODO parametize the revision list size

    def log
        `svn log --limit=5 svn://svn.berlios.de/motiro`
    end
    
end                                                           