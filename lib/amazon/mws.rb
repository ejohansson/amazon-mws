require 'cgi'
require 'uri'
require 'openssl'
require 'net/https'
require 'time'
require 'date'
require 'hmac'
require 'hmac-sha2'
require 'base64'
require 'builder'
require "rexml/document"
require 'roxml'

$:.unshift(File.dirname(__FILE__))
require 'mws/lib/extensions'
require 'builder'
require 'mws/lib/memoizable'
require 'mws/feed_builder'

# Request files implement functionality for specific Amazon API Requests
Dir.glob(File.join(File.dirname(__FILE__), 'mws/request/*.rb')).each {|f| require f }

# Node gives standard ROXML properties for parsing XML
require 'mws/node'

# Response parsing added to node
require 'mws/response'
Dir.glob(File.join(File.dirname(__FILE__), 'mws/response/*.rb')).each {|f| require f }

require 'mws/base'
require 'mws/exceptions'
require 'mws/connection'
require 'mws/connection/request_builder'
require 'mws/authentication'
require 'mws/authentication/query_string'
require 'mws/authentication/signature'

Amazon::MWS::Base.class_eval do
  include Amazon::MWS::Feeds
  include Amazon::MWS::Reports
  include Amazon::MWS::Orders
  include Amazon::MWS::Fulfillment
end

gem 'xml-simple'
