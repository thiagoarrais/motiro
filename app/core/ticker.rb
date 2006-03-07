require 'reporters/svn_driver'

class Ticker < ActiveRecord::Base
   background :tick_drivers, :every => 10.minute
   
   @@svnDriver = SubversionDriver.new

   def self.tick_drivers
       @@svnDriver.tick
   end
   
end