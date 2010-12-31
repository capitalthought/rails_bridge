module RailsBridge
end

require 'active_support/core_ext/class'
require 'active_support/core_ext/hash'
require 'active_support/cache'
$libdir = File.join( File.dirname(__FILE__), 'rails_bridge' )
require File.join( $libdir, 'content_request' )
require File.join( $libdir, 'content_bridge' )

if defined? Rails
  require File.join( $libdir, 'engine' )
else
  RailsBridge::ContentBridge.cache = ActiveSupport::Cache.lookup_store(:memory_store)
end

