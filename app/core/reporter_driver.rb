require 'core/reporter_fetcher'

class ReporterDriver

  def initialize(fetcher=ReporterFetcher.new)
    @fetcher = fetcher
  end

  def tick
    @fetcher.active_reporters.each do |reporter|
      reporter.latest_headlines.each do |hl|
        hl.cache
      end
    end
  end

end