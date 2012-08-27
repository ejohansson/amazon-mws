module Amazon
  module MWS
    module Orders


      def get_orders_list(params ={})
        query_params = { 'Action' => 'ListOrders' }
        query_params.merge!({"CreatedAfter" => params[:created_after]}) if params[:created_after]
        query_params.merge!({"CreatedBefore" => params[:created_before]}) if params[:created_before]
        query_params.merge!({"LastUpdatedAfter" =>params[:last_updated_after]}) if params[:last_updated_after]
        query_params.merge!({"LastUpdatedBefore" => params[:last_updated_before]}) if params[:last_updated_before]
        query_params.merge!({"BuyerEmail" => params[:buyer_email]}) if params[:buyer_email]
        query_params.merge!({"SellerOrderId" => params[:seller_order_id]}) if params[:seller_order_id]
        query_params.merge!({"MaxResultsPerPage" => params[:results_per_page]}) if params[:results_per_page]
        
        params[:fulfillment_channel].to_a.each_with_index{|channel,i| query_params.merge!({"FulfillmentChannel.Channel.#{i+1}" => channel})} if params[:fulfillment_channel]
        params[:order_status].to_a.each_with_index{|status,i| query_params.merge!({"OrderStatus.Status.#{i+1}" => status})} if params[:order_status]
        params[:marketplace_id].to_a.each_with_index{|id,i| query_params.merge!({"MarketplaceId.Id.#{i+1}" => id})} if params[:marketplace_id]

        response = post("/Orders/#{Authentication::ORDERS_VERSION}", query_params)
        return response if params[:raw_xml]
        RequestOrdersResponse.format(response)
      end


      def get_orders_list_by_next_token(params ={})
        raise MissingRequiredParameter unless params[:next_token]
        query_params = { 
          'Action' => 'ListOrdersByNextToken', 
          'NextToken' => params[:next_token] }
        response = post("/Orders/#{Authentication::ORDERS_VERSION}", query_params)
        return response if params[:raw_xml]
        RequestOrdersByNextTokenResponse.format(response)
      end


      def get_list_order_items(params ={})
        amazon_order_id = params[:amazon_order_id]
        query_params = { 'Action' => 'ListOrderItems' }
        query_params.merge!({"AmazonOrderId" => amazon_order_id}) if amazon_order_id
        response = post("/Orders/#{Authentication::ORDERS_VERSION}", query_params)
        return response if params[:raw_xml]
       	RequestOrderItemsResponse.format(response)
      end


      def get_list_order_items_by_next_token(params ={})
        raise MissingRequiredParameter unless params[:next_token]
        query_params = {
          'Action' => 'ListOrderItemsByNextToken',
          'NextToken' => params[:next_token] }
        response = post("/Orders/#{Authentication::ORDERS_VERSION}", query_params)
        return response if params[:raw_xml]
        RequestOrderItemsByNextTokenResponse.format(response)
      end


      def get_orders(params ={})
        query_params = { 'Action' => "GetOrder" }
        params[:amazon_order_id].to_a.each_with_index{|id,i| query_params.merge!({"AmazonOrderId.Id.#{i+1}" => id})} if params[:amazon_order_id]
        response = post("/Orders/#{Authentication::ORDERS_VERSION}", query_params)
        return response if params[:raw_xml]
        RequestOrdersResponse.format(response)
      end

    end
  end
end
