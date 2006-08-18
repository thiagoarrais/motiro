require 'core/settings'
require 'ports/reporter_loader'

require 'reporters/events_reporter'

class ReporterFetcher

  def initialize(settings=SettingsProvider.new, loader=ReporterLoader.new)
    @settings, @loader = settings, loader
  end
  
  def active_reporters
    reporters = @settings.active_reporter_ids.map do |rid|
      @loader.create_reporter(rid)
    end
    
    reporters << EventsReporter.new
  end

end