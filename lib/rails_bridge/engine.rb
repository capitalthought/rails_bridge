module RailsBridge
  # namespace our plugin and inherit from Rails::Railtie
  # to get our plugin into the initialization process
  class Engine < Rails::Engine

    # initialize our plugin on boot. 
    initializer "rails_bridge.initialize" do |app|
    end
    
    config.after_initialize do
      RailsBridge::ContentBridge.logger = Rails.logger
      RailsBridge::ContentBridge.cache = Rails.cache
    end
    
  end
end
