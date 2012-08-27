require 'test_helper'

class OrdersTest < MiniTest::Unit::TestCase

  NEXT_TOKEN = '>9Sy1rjELHa2v06krKetbKrtwX7u5furPkr1n0nQYpwbNeGyEmOrLe7q8xqAchQNKurwYODTEdyqfJudhyYNc3fBN7lmKh5MlkHdivTziOHySXS65MVd54C88gfetEbGyGRFlAxb7U+eIBJtw5YQ8FDkC5gCMX3pTkWJZSz0xK1jWd/9Nyx/qDb+ZPyEg4XuzI9jEWs+xHadFX56hGcf21iVPmzhWL2hkkWxTwkMTFhirNZST/hMq2s+uAlnst6Vo8u7BHPNLl2qLGNRdpjPaV/R76L5V7brQx+mIjiAqdq7XKs1Ol1dxk5J7UX1K6D3SrVAlRqj6TtUD2s1QD6a1FegLh44xPVWbZvsy0W2YjOIO+BUh5AtWjoNqlERy2ZulUJHWppbPRMZyYJp4zi6rPGQ=='

  def setup
		@config = YAML.load_file( File.join(File.dirname(__FILE__), 'test_config.yml') )['test']
		@connection = Amazon::MWS::Base.new(@config)
  end

  def test_get_orders_list
  	@connection.stubs(:post).returns(xml_for('request_orders',200))
  	date = DateTime.parse('2010-10-05T18:12:20.000Z')
		response = @connection.get_orders_list(
			:last_updated_after => date.iso8601,
			:results_per_page => 100,
      :fulfillment_channel => ["MFN","AFN"],
			:order_status => ["Unshipped", "PartiallyShipped", "Shipped", "Unfulfillable"],
			:marketplace_id => ['ATVPDKIKX0DER']
		)
		assert_kind_of RequestOrdersResponse, response
		assert !response.accessors.include?("code")
		assert_equal '2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=', response.next_token
		assert_equal date.iso8601, response.last_updated_before.iso8601
		
		assert_kind_of Hash, response.as_hash

		response = @connection.get_orders_list(:raw_xml => true)
		assert_kind_of Net::HTTPOK, response
  end
  
  # to test query string
  def test_get_orders_list_by_next_token_not_stubbed
		response = @connection.get_orders_list_by_next_token(:next_token => NEXT_TOKEN)
		assert_kind_of ResponseError, response    
  end
  
  def test_get_orders_list_by_next_token
  	@connection.stubs(:post).returns(xml_for('request_orders_by_next_token',200))
		response = @connection.get_orders_list_by_next_token(:next_token => NEXT_TOKEN)
		assert_kind_of RequestOrdersByNextTokenResponse, response
		
		assert !response.accessors.include?("code")
    assert_equal DateTime.parse('2012-04-18T20:57:22.000Z').iso8601, response.last_updated_before.iso8601
    assert_equal '134-562342326-223434325', response.orders[0].amazon_order_id
    assert_equal '133-5333444-743334440', response.orders[1].amazon_order_id
    
    response = @connection.get_orders_list_by_next_token(:next_token =>NEXT_TOKEN, :raw_xml => true)
		assert_kind_of Net::HTTPOK, response
  end
  
  def test_get_list_order_items
  	@connection.stubs(:post).returns(xml_for('request_order_items',200))  
		response = @connection.get_list_order_items(:amazon_order_id => '134-562342326-223434325')
		assert_kind_of RequestOrderItemsResponse, response
		
		response = @connection.get_list_order_items(:raw_xml => true)
		assert_kind_of Net::HTTPOK, response		
  end
  
  def test_get_list_order_items_by_next_token
  	@connection.stubs(:post).returns(xml_for('request_order_items_by_next_token',200))    
		response = @connection.get_list_order_items_by_next_token(:next_token => NEXT_TOKEN)
		assert_kind_of RequestOrderItemsByNextTokenResponse, response
		
		response = @connection.get_list_order_items_by_next_token(:next_token => NEXT_TOKEN, :raw_xml => true)
		assert_kind_of Net::HTTPOK, response
  end

  def test_get_orders
  	@connection.stubs(:post).returns(xml_for('orders_request',200))   
    orders_arr = ['134-562342326-223434325', '133-5333444-743334440']
    response = @connection.get_orders(:amazon_order_id=> orders_arr)
    assert_kind_of RequestOrdersResponse, response
    
		response = @connection.get_orders(:raw_xml => true)
		assert_kind_of Net::HTTPOK, response    
  end

end