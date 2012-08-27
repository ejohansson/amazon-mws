module Amazon
  module MWS

    class OrderResponse < Node
      xml_name "Order"
      
      xml_reader :amazon_order_id
      xml_reader :seller_order_id
      xml_reader :purchase_date, :as => DateTime
      xml_reader :last_update_date, :as => DateTime
      xml_reader :order_status
      xml_reader :fulfillment_channel
      xml_reader :sales_channel
      xml_reader :order_channel
      xml_reader :ship_service_level

      xml_reader :amount, :in => "xmlns:OrderTotal", :as => Float
      xml_reader :currency_code, :in => "xmlns:OrderTotal"

      xml_reader :name, :in => "xmlns:ShippingAddress"
      xml_reader :address_line_1, :in => "xmlns:ShippingAddress"
      xml_reader :address_line_2, :in => "xmlns:ShippingAddress"
      xml_reader :address_line_3, :in => "xmlns:ShippingAddress"
      xml_reader :city, :in => "xmlns:ShippingAddress"
      xml_reader :county, :in => "xmlns:ShippingAddress"
      xml_reader :district, :in => "xmlns:ShippingAddress"
      xml_reader :state_or_region, :in => "xmlns:ShippingAddress"
      xml_reader :postal_code, :in => "xmlns:ShippingAddress"
      xml_reader :country_code, :in => "xmlns:ShippingAddress"
      xml_reader :phone, :in => "xmlns:ShippingAddress"

      xml_reader :number_of_items_shipped, :as => Integer
      xml_reader :number_of_items_unshipped, :as => Integer
      xml_reader :marketplace_id
      xml_reader :buyer_name
      xml_reader :buyer_email
      xml_reader :shipment_service_level_category

    end

    class RequestOrdersResponse < Response
      xml_name "ListOrdersResponse"
      result = "ListOrdersResult"
      namespace = "xmlns:"

       xml_reader :next_token, :in => result
       xml_reader :last_updated_before, :in => result, :as => DateTime
       xml_reader :request_id, :in => "ResponseMetadata"
       xml_reader :orders, :as => [OrderResponse], :in => namespace + result + "/" + namespace + "Orders"
    end

    class RequestOrdersByNextTokenResponse < Response
      xml_name "ListOrdersByNextTokenResponse"
      result = "ListOrdersByNextTokenResult"
      namespace = "xmlns:"

       xml_reader :next_token, :in => result
       xml_reader :last_updated_before, :in => result, :as => DateTime
       xml_reader :request_id, :in => "ResponseMetadata"
       xml_reader :orders, :as => [OrderResponse], :in => namespace + result + "/" + namespace + "Orders"
    end

  end
end
