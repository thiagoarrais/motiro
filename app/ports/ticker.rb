require 'reporters/svn_driver'
require 'reporters/svn_settings'

class Ticker < ActiveRecord::Base

    interval = SettingsProvider.new.getUpdateInterval

    if interval != 0 then
        background :tick_drivers, :every => interval.minute
    end
   
    @@svnDriver = SubversionDriver.new

    def self.tick_drivers
        @@svnDriver.tick
    end

end