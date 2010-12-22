def running_in_textmate?
  ENV["TM_PROJECT_DIRECTORY"]
end

if running_in_textmate? && ENV["TM_SHOW_LOGS"]
  class Logger
    alias :orig_info :info
    alias :orig_debug :debug
    alias :orig_warn :warn
    alias :orig_error :error
    
    def textmate_wrap string
      string + "<br/>"
    end
    
    def info string; puts textmate_wrap( string ); end
    def debug string; puts textmate_wrap( string ); end
    def warn string; puts textmate_wrap( string ); end
    def error string; puts textmate_wrap( string ); end
    
  end
end