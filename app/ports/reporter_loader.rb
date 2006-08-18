# Loads a reporter from the local filesystem
class ReporterLoader

  def create_reporter(reporter_id)
    require "reporters/#{reporter_id}_reporter"
    eval "#{reporter_id.camelize}Reporter.new"
  end

end