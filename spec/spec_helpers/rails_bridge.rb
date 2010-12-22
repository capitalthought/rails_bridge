log_filename = File.join(File.dirname(__FILE__),'..','..','log','test.log')

if defined?(LOG_TO_STDOUT) && LOG_TO_STDOUT
  if defined? Rails
    Rails.logger = Logger.new(STDOUT)
  end
else
  RailsBridge::ContentBridge.logger = Logger.new(File.open(log_filename,'w')) unless defined?( Rails )
end