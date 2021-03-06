module Amazon
  module MWS
    module Feeds

      # Note: We do not handle flat file feed types
      FEED_TYPES = {
        :product_data              => '_POST_PRODUCT_DATA_',
        :product_relationship_data => '_POST_PRODUCT_RELATIONSHIP_DATA_',
        :item_data                 => '_POST_ITEM_DATA_',
        :product_overrides         => '_POST_PRODUCT_OVERRIDES_DATA_',
        :product_image_data        => '_POST_PRODUCT_IMAGE_DATA_',
        :product_pricing           => '_POST_PRODUCT_PRICING_DATA_',
        :inventory_availability    => '_POST_INVENTORY_AVAILABILITY_DATA_',
        :order_acknowledgement     => '_POST_ORDER_ACKNOWLEDGEMENT_DATA_',
        :order_fulfillment         => '_POST_ORDER_FULFILLMENT_DATA_',
        :payment_adjustment        => '_POST_PAYMENT_ADJUSTMENT_DATA_'
      }

      MESSAGE_TYPES = [
        "FulfillmentCenter",
        "Inventory",
        "OrderAcknowledgement",
        "OrderAdjustment",
        "OrderFulfillment",
        "OrderReport",
        "Override",
        "Price",
        "ProcessingReport",
        "Product",
        "ProductImage",
        "Relationship",
        "SettlementReport"
      ]

      PRODUCT_MESSAGE_TYPES = [
        "Product",
        "Price",
        "ProductImage",
        "Relationship",
        "Inventory"
      ]

      PROCESSING_STATUSES = {
        :submitted => '_SUBMITTED_',
        :in_progress => '_IN_PROGRESS_',
        :done => '_DONE_',
        :completed => '_COMPLETED_'
      }

      # The SubmitFeed operation uploads a file for processing together with
      # the necessary metadata to process the file.

      # Amazon MWS limits calls to 1,000 total calls per hour per seller
      # account. For best performance, you should limit your calls to
      # SubmitFeed to no more than three feeds per hour per seller account,
      # although you can successfully call SubmitFeed up to 30 times per
      # hour. Feed size is limited to 2,147,483,647 bytes (2^32 -1) per
      # feed.

      def submit_flat_file_feed(records, purge_flag = false)
        header = "sku\tproduct-id\tproduct-id-type\tprice\titem-condition\tquantity\tadd-delete\twill-ship-internationally\texpedited-shipping\titem-note\tfulfillment-center-id"
        query_params = {
          'Action' => 'SubmitFeed',
          'FeedType' => "_POST_FLAT_FILE_INVLOADER_DATA_" }
        query_params['PurgeAndReplace'] = 'true' if purge_flag
        response = post("/", query_params, ([header] + records).join("\r"))
        result = SubmitFeedResponse.format(response)
      end

      # params can contain {:purge => true and marketplace id list }
      def submit_feed(feed_type, message_type, messages = [], params = {})
        message_type= message_type.to_s.camelize
        raise InvalidMessageType if !MESSAGE_TYPES.include?(message_type)
        raise "Missing merchant_id" unless @merchant_id
        
        body = Amazon::MWS::FeedBuilder.new(message_type, messages, params.merge({:merchant_id => @merchant_id})).render
        puts body if Amazon::MWS::Base.debug
        
        response =
          post("/", {
          "Action"   => "SubmitFeed",
          "FeedType" => FEED_TYPES[feed_type]
        }, body)

        result = SubmitFeedResponse.format(response)
      end

      alias_method :submit, :submit_feed

      # The GetFeedSubmissionList operation returns the total list of feed
      # submissions within the previous 90 days that match the query
      # parameters. Amazon MWS limits calls to 1,000 total calls per hour
      # per seller account, including calls to GetFeedSubmissionList.
      #
      # The maximum number of results that will be returned in one call is
      # one hundred. If there are additional results to return, HasNext will
      # be returned in the response with a true value. To retrieve all the
      # results, you can use the value of the NextToken parameter to call
      # GetFeedSubmissionListByNextToken until HasNext is false.

      # Optional Request Parameters
      # ------------------
      # FeedSubmissionIdList
      # A structured list of feed submission IDs. If you pass in explicit
      # IDs in this call, the other conditions, if specified, will be
      # ignored.

      # MaxCount
      # Maximum number of feed submissions to return in the list. If you
      # specify a number greater than 100, the call will be rejected.

      # FeedTypeList
      # A structured list of one or more FeedType constants by which to
      # filter feed submissions.

      # FeedProcessingStatusList
      # A structured list of one or more feed processing statuses by which
      #  to filter feed submissions. Valid values are:
      #
      # _SUBMITTED_
      # _IN_PROGRESS_
      # _CANCELLED_
      # _DONE_

      # SubmittedFromDate
      # The earliest submission date you are looking for, in ISO8601 date
      #  format (for example, "2008-07-03T18:12:22Z" or
      #  "2008-07-03T18:12:22.093-07:00").

      # SubmittedToDate
      # The latest submission date you are looking for, in ISO8601 date
      # format (for example, "2008-07-03T18:12:22Z" or
      # "2008-07-03T18:12:22.093-07:00").

      def get_feed_submission_list(params = {})
       response = get("/", {"Action" => "GetFeedSubmissionList"}.merge(params))
       result = GetFeedSubmissionListResponse.format(response)
      end

      alias_method :feed_submission_list, :get_feed_submission_list

      # The GetFeedSubmissionListByNextToken operation returns a list of
      # feed submissions that match the query parameters, using the
      # NextToken, which was supplied by a previous call to either
      # GetFeedSubmissionListByNextToken or a call to GetFeedSubmissionList,
      # where the value of HasNext was true in that previous call.
      #
      # Request Parameters
      # ------------------
      # NextToken
      # Token returned in a previous call to either GetFeedSubmissionList or
      # GetFeedSubmissionListByNextToken when the value of HasNext was true.
      def get_feed_submission_list_by_next_token(next_token)
        response =
         get("/", {
           "Action"   => "GetFeedSubmissionListByNextToken",
           "NextToken" => next_token
         })

         GetFeedSubmissionListByNextTokenResponse.format(response)
      end

      alias_method :feed_submission_list_by_next_token, :get_feed_submission_list_by_next_token

      # The GetFeedsubmissionCount operation returns a count of the total
      # number of feed submissions within the previous 90 days.
      #
      # Optional Request Parameters
      # ------------------
      # FeedTypeList
      # A structured list of one or more FeedType constants by which to
      # filter feed submissions.

      # FeedProcessingStatusList
      # A structured list of one or more feed processing statuses by which
      # to filter feed submissions. Valid values are:
      #
      # _SUBMITTED_
      # _IN_PROGRESS_
      # _CANCELLED_
      # _DONE_

      #  SubmittedFromDate
      #  The earliest submission date you are looking for, in ISO8601 date
      # format (for example, "2008-07-03T18:12:22Z" or
      # "2008-07-03T18:12:22.093-07:00").

      # SubmittedToDate
      # The latest submission date you are looking for, in ISO8601 date
      # format (for example, "2008-07-03T18:12:22Z" or
      # "2008-07-03T18:12:22.093-07:00").

      def get_feed_submission_count(params = {})
        response = get("/", {"Action" => "GetFeedSubmissionCount"}.merge(params))
        GetFeedSubmissionCountResponse.format(response)
      end

      alias_method :feed_submission_count, :get_feed_submission_count

      # The CancelFeedSubmissions operation cancels one or more feed
      # submissions, returning the count of the canceled feed submissions
      # and the feed submission information. You can specify a number to
      # cancel of greater than one hundred, but information will only be
      # returned about the first one hundred feed submissions in the list.
      # To return metadata about a greater number of canceled feed
      # submissions, you can call GetFeedSubmissionList. If feeds have
      # already begun processing, they cannot be canceled.

      # Amazon MWS limits calls to 1,000 total calls per hour per seller
      # account, including calls to CancelFeedSubmissions.

      # Optional Request Parameters
      # ------------------
      # FeedSubmissionIdList
      # A structured list of feed submission IDs. If you pass in explicit
      # IDs in this call, the other conditions, if specified, will be
      # ignored.

      # FeedTypeList
      # A structured list of one or more FeedType constants by which to
      # filter feed submissions.

      # SubmittedFromDate
      # The earliest submission date you are looking for, in ISO8601 date
      # format (for example, "2008-07-03T18:12:22Z" or
      # "2008-07-03T18:12:22.093-07:00").

      # SubmittedToDate
      # The latest submission date you are looking for, in ISO8601 date
      # format (for example, "2008-07-03T18:12:22Z" or
      # "2008-07-03T18:12:22.093-07:00").

      def cancel_feed_submissions(params = {})
        response =
        get("/", {"Action" => "CancelFeedSubmissions"}.merge(params))

        CancelFeedSubmissionsResponse.format(response)
      end

      # The GetFeedSubmissionResult operation returns the feed processing
      # report and the Content-MD5 header for the returned body.

      # You should compute the MD5 hash of the HTTP body that we returned to
      # you, and compare that with the Content-MD5 header value that we
      # returned. If they do not match, which means the body was corrupted
      # during transmission, you should discard the result and automatically
      # retry the call for up to three more times. Please notify us if you
      # ever see such a corrupted body. You can contact us by using the
      # contact form at http://mws.amazon.com (http://mws.amazon.com). For
      # more information on computing the MD5, see Using the Content-MD5
      # Header with SubmitFeed.

      # FeedSubmissionId
      # The identifier of the feed submission to get results for. Obtained
      # by a call to GetFeedSubmissionList.

      def get_feed_submission_result(feed_submission_id, params = {})
        response = get("/", {
          "Action"           => "GetFeedSubmissionResult",
          "FeedSubmissionId" => feed_submission_id
        }.merge(params))

        GetFeedSubmissionResultResponse.format(response)
      end

      alias_method :feed_submission_result, :get_feed_submission_result
    end

  end
end
