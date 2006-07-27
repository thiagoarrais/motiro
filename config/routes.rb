ActionController::Routing::Routes.draw do |map|

  locale_defaults = { :locale => nil }

  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  map.connect 'report/:reporter',
              :controller => 'report',
              :action => 'show',
              :format => 'html_fragment'
  
  map.connect 'feed/:reporter',
              :controller => 'report',
              :action => 'show',
              :format => 'rss'

  map.connect 'wiki/:action/:page/:locale', :controller => 'wiki',
              :defaults => locale_defaults
              
  map.connect 'events/:action/:locale', :controller => 'events',
              :defaults => locale_defaults

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
