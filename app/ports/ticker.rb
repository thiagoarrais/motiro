require 'core/reporter_driver'
require 'core/settings'

class Ticker < ActiveRecord::Base

  interval = SettingsProvider.new.update_interval

  background :tick_drivers, :every => interval.minute if interval != 0

  @@driver = ReporterDriver.new

  def self.tick_drivers
    @@driver.tick
  end

end