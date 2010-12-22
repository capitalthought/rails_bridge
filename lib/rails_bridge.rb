module RailsBridge
end

require 'active_support/core_ext/class'
require 'active_support/core_ext/hash'
$basedir = File.dirname(__FILE__)
require File.join( $basedir, 'rails_bridge', 'content_bridge' )
require File.join( $basedir, 'rails_bridge', 'content_request' )

# if defined? Rails
#   RailsBridge::ContentBridge.logger = Rails.logger
# end
# 
