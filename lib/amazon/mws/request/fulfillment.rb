module Amazon
  module MWS
    module Fulfillment

      #POST /FulfillmentInventory/2010-10-01?AWSAccessKeyId=XXXXXXX
      #  &Action=ListInventorySupply
      #  &SellerId=XXXXXXX
      #  &SignatureVersion=2
      #  &Timestamp=2012-08-27T13%3A04%3A58Z
      #  &Version=2010-10-01
      #  &Signature=kPjXXXXXXXXXXXXXXXXXXXXXXXpkX%2FtR211DXU%3D
      #  &SignatureMethod=HmacSHA256
      #  &QueryStartDateTime=2012-07-31T23%3A00%3A00Z
      #  &ResponseGroup=Basic HTTP/1.1
      def list_inventory_supply(params ={})
        query_params = { "Action" => "ListInventorySupply" }

        # Specifying both QueryStartDateTime and SellerSkus returns an error.
        if params[:query_start_date_time]
          query_params.merge!({'QueryStartDateTime' => params[:query_start_date_time]})
        elsif params[:seller_skus]
          params[:seller_skus].to_a.each_with_index{|sku,i| query_params.merge!({"SellerSkus.member.#{i+1}" => sku})}
        else
          raise MissingRequiredParameter
        end
        
        query_params.merge!({"ResponseGroup" => params[:response_group]}) if params[:response_group]
        response = post("/FulfillmentInventory/#{Authentication::INVENTORY_VERSION}", query_params)
        return response if params[:raw_xml]
        ListInventorySupplyResponse.format(response)
      end


      def list_inventory_supply_by_next_token(params ={})
        raise MissingRequiredParameter unless params[:next_token]
        query_params = { 
          'Action' => 'ListInventorySupplyByNextToken',
           'NextToken' => params[:next_token] }
        response = post("/FulfillmentInventory/#{Authentication::INVENTORY_VERSION}", query_params)
        return response if params[:raw_xml]
        ListInventorySupplyByNextTokenResponse.format(response)
      end

    end
  end
end
