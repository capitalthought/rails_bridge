module RailsBridge
  ROOT_PATH = 'app/rails_bridge'
  LAYOUTS_PATH = File.join(ROOT_PATH, 'layout_bridge', 'layouts')
  VIEWS_PATH = File.join(ROOT_PATH, 'layout_bridge', 'views')

  # namespace our plugin and inherit from Rails::Railtie
  # to get our plugin into the initialization process
  class Engine < Rails::Engine
    

    # initialize our plugin on boot. 
    initializer "rails_bridge.initialize" do |app|
    end
    
    config.after_initialize do
      RailsBridge::ContentBridge.logger = Rails.logger
      RailsBridge::ContentBridge.cache = Rails.cache
      RailsBridge::Engine.create_rails_bridge_home
    end
    
    config.autoload_paths << ROOT_PATH
    
    def self.create_rails_bridge_home
      rails_bridge_home = File.join( Rails.root, RailsBridge::ROOT_PATH )
      FileUtils.mkdir_p( rails_bridge_home ) unless File.exist?( rails_bridge_home )
      layout_bridge_views_path = File.join( Rails.root, RailsBridge::VIEWS_PATH )
      layout_bridge_layouts_path = File.join( Rails.root, RailsBridge::LAYOUTS_PATH )
      FileUtils.mkdir_p( layout_bridge_views_path ) unless File.exist?( layout_bridge_views_path )
      FileUtils.mkdir_p( layout_bridge_layouts_path ) unless File.exist?( layout_bridge_layouts_path )
      rails_bridge_home
    end
    
  end
end
