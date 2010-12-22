module RailsBridge
end

require 'active_support/core_ext/class'
require 'active_support/core_ext/hash'
$basedir = File.dirname(__FILE__)
require File.join( $basedir, 'rails_bridge', 'content_bridge' )
require File.join( $basedir, 'rails_bridge', 'content_request' )

if defined? Rails
  module RailsBridge
    # namespace our plugin and inherit from Rails::Railtie
    # to get our plugin into the initialization process
    class Railtie < Rails::Railtie

      # initialize our plugin on boot. 
      initializer "rails_bridge.initialize" do |app|
      end
      
      config.after_initialize do
        RailsBridge::ContentBridge.logger = Rails.logger
        RailsBridge::ContentBridge.cache = Rails.cache
      end
      
    end
  end
  
  # class RailsBridge::LoggerProxy
  #   def method_missing method, *args
  #     Rails.logger.send( method, *args )
  #   end
  # end
  # RailsBridge::ContentBridge.logger = RailsBridge::LoggerProxy.new
end

