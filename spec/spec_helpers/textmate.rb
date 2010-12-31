require 'cgi'
require 'logger'

def running_in_textmate?
  ENV["TM_PROJECT_DIRECTORY"]
end

class Logger
  def self.textmate_wrap string
    CGI.escapeHTML(string).gsub("\n", "<br/>")
  end
end
  
if running_in_textmate? && ENV["TM_SHOW_LOGS"]
  require 'active_support/core_ext/logger'
  class Logger
    alias :orig_info :info
    alias :orig_debug :debug
    alias :orig_warn :warn
    alias :orig_error :error
    
    def info string; puts Logger.textmate_wrap( string ); end
    def debug string; puts Logger.textmate_wrap( string ); end
    def warn string; puts Logger.textmate_wrap( string ); end
    def error string; puts Logger.textmate_wrap( string ); end
    
  end
end

def tm_safe_debug string
  if running_in_textmate?
    puts Logger.textmate_wrap( string ) + "<br/>"
  else
    Rails.logger.debug string
  end
end