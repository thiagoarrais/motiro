#  Motiro - A project tracking tool
#  Copyright (C) 2006-2007  Thiago Arrais
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require 'rubygems'
require 'active_support'

# A reporter is someone capable of going out for news
#
# For a Motiro reporter, "going out" may include, but is not limited to,
# accessing the local file system, executing external processes and consulting
# the web
class MotiroReporter

private

  OLDER_BUTTON = "link_to('Older'.t, :controller => 'report', " +
                                    ":action => 'older', :reporter => @name)"
  ADD_EVENTS_BUTTON = 
    "if current_user.nil?; " +
    "  content_tag('span', 'Add'.t, :class => 'disabled'); " +
    "else; " +
    "  link_to( 'Add'.t, :controller => 'events', :action => 'new'); " +
    "end;"

  NEW_FEATURE_BUTTON = 
    "if current_user.nil?; " +
    "  content_tag('span', 'Add'.t, :class => 'disabled'); " +
    "else; " +
    "  link_to( 'Add'.t, :controller => 'wiki', " + 
                        ":action => 'new', :kind => 'feature'); " +
    "end;"

public
  
  def self.reporter_name
    class_name = self.name
    return class_name[0, class_name.size - 8].underscore
  end
  
  # Replaces the default title with a custom one. Example usage:
  #
  #       class MyReporter < MotiroReporter
  #           title "This is my reporter's custom title"
  #       end
  #       
  #       MyReporter.new.channel_title => "This is my reporter's custom title"
  #
  # If not called, a default title will be generated based on the class name
  def self.title(title)
    define_method :channel_title do
      title.t
    end
  end
  
  # Adds a button to this reporter's toolbar. Accepts a text parameter that
  # will be fed into the ERB templates when generating web pages.
  # 
  # It is a better idea to use one of the buttons available on the buttons hash
  # than to hard-code the button code.
  def self.add(code)
    write_inheritable_array 'buttons', [code]
  end
  
  # A hash of buttons available for reporters
  # 
  # Usage : class MyReporter < MotiroReporter
  #           add_button buttons[:add_events]
  #         end
  def self.button
    @@buttons ||= { :older => OLDER_BUTTON,
                    :add_events => ADD_EVENTS_BUTTON,
                    :new_feature => NEW_FEATURE_BUTTON }
  end
  
  # Turns caching on and off for the reporter
  # 
  # Usage : class MyReporter < MotiroReporter
  #           caching :off
  #         end
  def self.caching(switch)
    define_method :cache? do; :off != switch; end
  end
  
  def name
    return self.class.reporter_name
  end
  
  def channel_title
    return 'Latest news from %s' / name.humanize
  end
  
  def buttons
    self.class.read_inheritable_attribute 'buttons' || []
  end
  
  def cache?; true; end

  def latest_headline
    return latest_headlines.first
  end
  
  def latest_headlines; end
  
  add button[:older]
  
end