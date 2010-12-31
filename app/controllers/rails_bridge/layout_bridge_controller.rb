module RailsBridge
  class LayoutBridgeController < ::ApplicationController
    def index
      paths = self.view_paths
      @layouts = {}
      paths.each do |path|
        layouts_path = File.join(path, 'layouts', '*.{erb,haml}')
        files = Dir.glob( File.join(path, 'layouts', '*.{erb,haml}') )
        files.each do |file|
          name = File.basename(file).split('.').first
          next if name =~ /^_.*/ # ignore partials
          @layouts[name] ||= file # only the first matching layout in the views path is accessible
        end
      end
      
    end

    def show
      @layout_name = params[:id]
      custom_content_path = File.join( Rails.root, RailsBridge::LAYOUTS_PATH, @layout_name )
      bridge_views_path = File.join( Rails.root, RailsBridge::VIEWS_PATH )
      self.prepend_view_path(custom_content_path)
      self.prepend_view_path(bridge_views_path)
      string = replace_relative_urls( render_to_string :layout=>@layout_name, :template=>'content' )
      render :text=>string, :content_type=>'text/plain'
    end
    
    private
    
      def replace_relative_urls html
        substitutions = [
          [/(<a.*?href\s*=\s*")\//, "$1#{site_url}/"],            # replace anchor URLs
          [/(<script.*?src\s*?=\s*?")\//, "$1#{site_url}/"],      # replace script URLs
          [/(<link.*?href\s*=\s*")\//, "$1#{site_url}/"]          # replace stylesheet URLs
        ]
        html.mgpsub( substitutions )
      end
      
      def site_url
        (defined?(RailsBridge::SITE_URL) && RailsBridge::SITE_URL) || "#{request.env['rack.url_scheme']}://#{request.host}:#{request.port}"
      end
  end
end