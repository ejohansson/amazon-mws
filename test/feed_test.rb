require 'test_helper'

class FeedTest < MiniTest::Unit::TestCase
  def setup
		@config = YAML.load_file( File.join(File.dirname(__FILE__), 'test_config.yml') )['test']
		@connection = Amazon::MWS::Base.new(@config)
  end

  def test_submit_feed_non_stubbed
		response = @connection.submit_feed(:product_data,'Product',[{ 'sku'=>'234234234234', 'product-name'=>'name name name' }])
    assert_kind_of ResponseError, response    
  end

  def test_submit_flat_file_feed
    @connection.stubs(:post).returns(xml_for('submit_feed',200))
		response = @connection.submit_flat_file_feed(["234234234234\tname name name\t"],false)
    assert_kind_of SubmitFeedResponse, response
  end

  def test_submit_feed
  	@connection.stubs(:post).returns(xml_for('submit_feed',200)) 

    messages = [{
      #'MessageID' => 2,
      'OperationType' => 'Update',
      'Product'=> {
        'SKU'=>'sku1324234324',
        'ItemPackageQuantity'=>'1',
        'NumberOfItems'=>'1',
        'StandardProductID'=>{'Type'=>'UPC', 'Value'=>'814digitstring'},
        'DescriptionData'=>[
          {'Title'=>'title'},
          {'Brand'=>'brand'},
          {'Designer'=>'designer'},
          {'Description'=>'description'}, # max length 2000
          {'BulletPoint'=>'bp1'},
          {'BulletPoint'=>'bp2'}, # max 5
          {'ShippingWeight'=>['1'=>'2', 'unitOfMeasure'=>'LB']}, #TODO value is probably not the right term
          {'MSRP'=>'5.43'},
          {'SearchTerms' => 'asdf1'},
          {'SearchTerms' => 'asdf2'},
          {'IsGiftWrapAvailable'=>'True'},
          {'IsGiftMessageAvailable'=>'True'}
        ],#DescriptionData
        'ProductData' => {
          'Clothing'=>{
            "VariationData"=> {
              "Parentage"=>"child", 
              "Size"=>"size",
              "Color"=>"color",
              "VariationTheme"=>"SizeColor"
            }, #VariationData
            'ClassificationData'=>[
              {'ClothingType'=>'Accessory'},
              {'Department'=>'d1'},
              {'Department'=>'d2'}, # max 10 
              {'StyleKeywords'=>'style1'},
              {'StyleKeywords'=>'style2'},  # max 10
              {'OccasionAndLifestyle'=>'ol1'},
              {'OccasionAndLifestyle'=>'ol2'} # max 10
            ]#ClassificationData
          }#Clothing
        }#ProductData
      }#Product
    }]

		response = @connection.submit_feed('product_data','Product', messages)
    assert_kind_of SubmitFeedResponse, response
    assert_equal '2291326430', response.feed_submission.id
    assert_equal Feeds::PROCESSING_STATUSES[:submitted], response.feed_submission.feed_processing_status
    assert_equal Feeds::FEED_TYPES[:product_data], response.feed_submission.feed_type
  end
  
  def test_get_feed_submission_list_failure
    # Without stubbing, to test request code
    response = @connection.get_feed_submission_list
    assert_kind_of ResponseError, response  

    # With stubbing
    @connection.stubs(:get).returns(xml_for('error',401))
    response = @connection.get_feed_submission_list
    assert_kind_of ResponseError, response
    assert_equal 'AccessDenied', response.code
    assert_equal 'Access to the resource Marketplace MARKETPLACE_ID is not a valid marketplace is denied.', response.message
    assert_equal '75a808dd-72c6-4af4-b4ba-4b00f3153940', response.request_id
  end

  def test_get_feed_submission_list_success
    @connection.stubs(:get).returns(xml_for('get_feed_submission_list',200))
    response = @connection.get_feed_submission_list
    assert_kind_of GetFeedSubmissionListResponse, response
    assert_equal true, response.has_next?
    assert_equal '2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=', response.next_token
    assert_equal '1105b931-6f1c-4480-8e97-f3b467840a9e', response.request_id
    assert_equal 1, response.feed_submissions.count
    
    fs = response.feed_submissions.first    
    assert_equal '2291326430', fs.id
    assert_equal '_SUBMITTED_', fs.feed_processing_status
    assert_equal Time.parse('2009-02-20T02:10:35+00:00'), fs.submitted_date
    assert_equal Time.parse('2009-02-20T02:12:54+00:00'), fs.started_processing_date
    assert_equal Time.parse('2009-02-20T02:14:13+00:00'), fs.completed_processing_date
    assert_equal '_POST_PRODUCT_DATA_', fs.feed_type
  end

  def test_get_feed_submission_list_by_next_token
    @connection.stubs(:get).returns(xml_for('get_feed_submission_list_by_next_token',200))    
    response = @connection.get_feed_submission_list_by_next_token('234234234234234234')
    assert_kind_of GetFeedSubmissionListByNextTokenResponse, response
  end

  def test_get_feed_submission_count
    @connection.stubs(:get).returns(xml_for('get_feed_submission_count',200))    
    response = @connection.get_feed_submission_count
    assert_kind_of GetFeedSubmissionCountResponse, response
  end

  def test_cancel_feed_submissions
    @connection.stubs(:get).returns(xml_for('cancel_feed_submissions',200))    
    response = @connection.cancel_feed_submissions
    assert_kind_of CancelFeedSubmissionsResponse, response
  end

  def test_get_feed_submission_result
    @connection.stubs(:get).returns(xml_for('get_feed_submission_result',200))
    response = @connection.get_feed_submission_result('2342342342342342')
    assert_kind_of GetFeedSubmissionResultResponse, response

    assert_equal 'ProcessingReport', response.message_type
    assert_equal 1, response.message.id
    assert_equal '2060950676', response.message.document_transaction_id
    assert_equal 'Complete', response.message.status_code
    assert_equal 0, response.message.processing_summary.messages_processed
    assert_equal 0, response.message.processing_summary.messages_successful
    assert_equal 1, response.message.processing_summary.messages_with_error
    assert_equal 0, response.message.processing_summary.messages_with_warning
    assert_equal 1, response.message.results.count
    
    r = response.message.results.first
    assert_equal 0, r.message_id
    assert_equal 'Error', r.result_code
    assert_equal '6001', r.message_code
    assert_equal 'XML parsing fatal error at line 1, column 1: Invalid document structure', r.description
    assert_equal '0', r.sku
  end

end
