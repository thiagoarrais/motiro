require 'reporters/svn_reporter'

class ReporterLoader

  def create_reporter(reporter_id)
    return SubversionReporter.new
  end

end