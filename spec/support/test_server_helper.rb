require 'rubygems'
require 'eventmachine'
require 'cgi'
require 'pp'
require 'logger'

module HTTPHandler
  def extract_query_params( query )
    query = CGI::unescape( query )
    pairs = query.split("&")
    pairs.inject({}){|hash, pair| k,v=pair.split('='); v.nil? ? hash : (hash[k.to_sym]=v;hash)}
  end
  
  def http_request? data
    http_request = nil
    matches = data.split("\n").first.match(/(\w*) ([^\?]*)\??([^#]*)#?(.*) HTTP\/1\.1/)
    if matches
      http_request = {}
      http_request[:request] = matches[0]
      captures = matches.captures
      http_request[:command] = captures.shift
      http_request[:path] = captures.shift
      http_request[:query_params] = extract_query_params(captures.shift)
      http_request[:anchor] = captures.shift
    end
    # pp http_request
    http_request
  end

  def process_http_request( http_request )
    if sleep_time = http_request[:query_params][:sleep]
      sleep( sleep_time.to_i )
    end
    unless return_data = http_request[:query_params][:return_data]
      return_data = "Your HTTP Request(#{http_request[:request]}) was processed by the TestServer."
    end
    http_response(return_data)
  end
  
  def http_response( return_data, code=200 )
    headers = <<-TXT
HTTP/1.1 #{ code } OK 
Connection: Keep-Alive
Content-Type: text/html; charset=utf-8

TXT
    headers + return_data
  end
end

module TestServerModule
  
  def self.included(base)
    base.send(:include, HTTPHandler) unless base.include?( HTTPHandler )
  end
  
  def post_init
    puts 'got connection'
  end
  
  def receive_data(data)
    puts "Got data:\n#{data}"
    if http_request = http_request?( data )
      return_data = process_http_request( http_request )
    else
      return_data = "Your request was processed by the TestServer."
    end
    send_data(return_data)
    puts "Sent: #{return_data}"
    close_connection_after_writing
  end
  
  def puts string
    TestServer.logger.debug( string )
  end
  
end


class TestServer
  @@logger = Logger.new(STDOUT)
  @@thread = nil
  PORT = 1234

  def self.puts string
    self.logger.debug( string )
  end
  
  def self.logger
    @@logger
  end
  
  def self.logger= logger
    @@logger = logger
  end
  
  def self.startup( port=PORT )
    return if @@thread
    @@thread = Thread.new do 
      begin
        EM.run do
          EM.start_server "0.0.0.0", port, TestServerModule
        end
      rescue Interrupt
      end
    end
    puts "TestServer listening on port #{port}."
  end

  def self.shutdown
    return unless @@thread
    @@thread.kill
    @@thread.join
    puts "TestServer stopped."
    @@thread = nil
  end
end

if __FILE__ == $0
  require 'typhoeus'
  TestServer.startup
  response = Typhoeus::Request.get("http://localhost:1234/hi?sleep=1&return_data=verified")
  puts "response: #{response.inspect}"
  TestServer.shutdown
end