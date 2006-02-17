class Headline

    def author
    end

    def date
    end

    def title
    end

end

class SubversionReporter

    def initialize(connection)
    end

    def latest_headline
        Headline.new
    end

end
