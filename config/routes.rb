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

ActionController::Routing::Routes.draw do |map|

  locale_defaults = { :locale => nil }

  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  map.connect 'report/older/:reporter',
              :controller => 'report',
              :action => 'older'

  map.with_options(:controller => 'report', :action => 'list')  do |report|
    report.connect 'report/:reporter/:locale'
    report.connect 'report/:reporter/:locale.:format'
  end
              
  map.connect 'show/:reporter/:id', :controller => 'report', :action => 'show'
  
  map.connect 'wiki/new/:kind/:locale',
              :controller => 'wiki',
              :action => 'new',
              :defaults => locale_defaults.merge(:kind => 'common')

  map.connect 'wiki/last/:kind/:locale',
              :controller => 'wiki',
              :action => 'last',
              :defaults => locale_defaults.merge(:kind => 'common')

  map.connect 'wiki/:action/:locale',
              :controller => 'wiki',
              :requirements => { :action => /properties_(show|edit)/ },
              :defaults => locale_defaults

  map.connect 'wiki/:action/:page_name', :controller => 'wiki'
  map.connect 'wiki/:action/:page_name.:format', :controller => 'wiki'
              
  map.connect '', locale_defaults.merge(:controller => 'root',
                                        :action => 'index')

  map.connect ':locale', :controller => 'root', :action => 'index'
              
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id/:locale',
              :defaults => locale_defaults
end
