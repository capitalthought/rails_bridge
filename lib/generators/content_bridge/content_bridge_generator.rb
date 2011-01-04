  class ContentBridgeGenerator < Rails::Generators::NamedBase
    argument :requests, :type => :array, :default => [], :banner => "request [request]..."
    source_root File.expand_path('../templates', __FILE__)
    
    def create_class_file
      template 'content_bridge.rb', File.expand_path(File.join('app/rails_bridge', 'content_bridges', "#{file_name}.rb"))
    end
        
  end
