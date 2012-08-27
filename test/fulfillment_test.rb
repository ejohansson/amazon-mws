require 'test_helper'

class FulfillmentTest < MiniTest::Unit::TestCase

  NEXT_TOKEN = '>9Sy1rjELHa2v06krKetbKrtwX7u5furPkr1n0nQYpwbNeGyEmOrLe7q8xqAchQNKurwYODTEdyqfJudhyYNc3fBN7lmKh5MlkHdivTziOHySXS65MVd54C88gfetEbGyGRFlAxb7U+eIBJtw5YQ8FDkC5gCMX3pTkWJZSz0xK1jWd/9Nyx/qDb+ZPyEg4XuzI9jEWs+xHadFX56hGcf21iVPmzhWL2hkkWxTwkMTFhirNZST/hMq2s+uAlnst6Vo8u7BHPNLl2qLGNRdpjPaV/R76L5V7brQx+mIjiAqdq7XKs1Ol1dxk5J7UX1K6D3SrVAlRqj6TtUD2s1QD6a1FegLh44xPVWbZvsy0W2YjOIO+BUh5AtWjoNqlERy2ZulUJHWppbPRMZyYJp4zi6rPGQ=='

  def setup
		@config = YAML.load_file( File.join(File.dirname(__FILE__), 'test_config.yml') )['test']
		@connection = Amazon::MWS::Base.new(@config)
  end

  def test_list_inventory_supply
  	@connection.stubs(:post).returns(xml_for('list_inventory_supply',200))

    response = @connection.list_inventory_supply() rescue MissingRequiredParameter
		
		# With seller skus specified and Basic (default) resopnse group
		response = @connection.list_inventory_supply(:seller_skus => ['ABCD','CDSF','ASDFD'])

  	date = DateTime.parse('2010-10-05T18:12:20.000Z')
		response = @connection.list_inventory_supply(
			:query_start_date_time => date.iso8601,
			:response_group => 'Detailed'
		)
		assert_kind_of ListInventorySupplyResponse, response
		assert_equal 'XXXXXXXXXXXXXXXXXXXXX+gZl+XEt/FA197IDM9A7eTw3z9zCjiu83ltjgbEGPv8AwO5kWSUBAAA=', response.next_token
    assert_equal 'c29eb92e-XXXXXXXXXXXXXX-fbf17d81d7bc', response.request_id
		#puts response.inventory_supply_list.to_hash.inspect

		members = response.inventory_supply_list.members
    assert_equal 2, members.length
    m1 = members.first
    assert_kind_of InventorySupplyMember, m1
    assert_equal 'RRRRR4524-002-62', m1.seller_sku
    assert_equal 'BXXXXX8CZ5K', m1.asin
    assert_equal 1, m1.total_supply_quantity
    assert_equal 'X00XXXX21JD', m1.fnsku
    assert_equal 'NewItem', m1.condition
    assert_equal 1, m1.in_stock_supply_quantity
    assert_equal 'Immediately', m1.earliest_availability

    assert_kind_of SupplyDetail, m1.supply_detail
    assert_equal 'Immediately', m1.supply_detail.earliest_available_to_pick
    assert_equal 'Immediately', m1.supply_detail.latest_available_to_pick
    assert_equal 'InStock', m1.supply_detail.supply_type
    assert_equal 1, m1.supply_detail.quantity
    		
		assert_kind_of Hash, response.as_hash

		response = @connection.list_inventory_supply(:query_start_date_time=>date.iso8601, :raw_xml => true)
		assert_kind_of Net::HTTPOK, response
  end

  def test_list_inventory_supply_by_next_token
  	@connection.stubs(:post).returns(xml_for('list_inventory_supply_by_next_token',200))
		response = @connection.list_inventory_supply_by_next_token(:next_token => NEXT_TOKEN)
		assert_kind_of ListInventorySupplyByNextTokenResponse, response
		
		assert_equal 'XXXXXXXz8MIaewjewnYDvyi72ShmgFTDpDvSoOYzVM77VtakM33h3mNokSES59ORCxx6LFtfxbAXr7DS48AihZnz9AUE6/4IkAQAA', response.next_token
    assert_equal '21d4c58b-ba71-XXXXX-dea9d05158b0', response.request_id
    
    members = response.inventory_supply_list.members
    assert_equal 2, members.length
    m1 = members.first
    assert_kind_of InventorySupplyMember, m1
    assert_equal 'XXXX53-8234M2-62', m1.seller_sku
    assert_equal 'B0XXXXXVZE', m1.asin
    assert_equal 2, m1.total_supply_quantity
    assert_equal 'X0XXXXX201', m1.fnsku
    assert_equal 'NewItem', m1.condition
    assert_equal 2, m1.in_stock_supply_quantity
    assert_equal 'Immediately', m1.earliest_availability

    assert_kind_of SupplyDetail, m1.supply_detail
    assert_equal 'Immediately', m1.supply_detail.earliest_available_to_pick
    assert_equal 'Immediately', m1.supply_detail.latest_available_to_pick
    assert_equal 'InStock', m1.supply_detail.supply_type
    assert_equal 2, m1.supply_detail.quantity
    		
		assert_kind_of Hash, response.as_hash

		response = @connection.list_inventory_supply_by_next_token(:next_token=>NEXT_TOKEN, :raw_xml => true)
		assert_kind_of Net::HTTPOK, response
  end

end