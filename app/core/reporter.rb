# A reporter is someone capable of going out for news
#
# For a Motiro reporter, "going out" may include, but is not limited to,
# accessing the local file system, executing external processes and consulting
# the web
class MotiroReporter

    attr_reader :name

    def initialize(name)
        @name = name
    end

end