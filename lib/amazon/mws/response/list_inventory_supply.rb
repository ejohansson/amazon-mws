module Amazon
  module MWS

    #<SupplyDetail>
    #  <member>
    #    <EarliestAvailableToPick>
    #      <TimepointType>Immediately</TimepointType>
    #    </EarliestAvailableToPick>
    #    <Quantity>1</Quantity>
    #    <LatestAvailableToPick>
    #      <TimepointType>Immediately</TimepointType>
    #    </LatestAvailableToPick>
    #    <SupplyType>InStock</SupplyType>
    #  </member>
    #</SupplyDetail>

    class SupplyDetail < Node
      xml_name "member"
      xml_reader :quantity, :as => Integer
      xml_reader :supply_type
      xml_reader :earliest_available_to_pick, :in => 'EarliestAvailableToPick', :from=>'TimepointType'
      xml_reader :latest_available_to_pick, :in => 'LatestAvailableToPick', :from=>'TimepointType'
    end

    #<SellerSKU>RRRRR4524-002-62</SellerSKU>
    #<ASIN>BXXXXX8CZ5K</ASIN>
    #<TotalSupplyQuantity>1</TotalSupplyQuantity>
    #<FNSKU>X00XXXX21JD</FNSKU>
    #<Condition>NewItem</Condition>
    #<InStockSupplyQuantity>1</InStockSupplyQuantity>
    #<SupplyDetail/>
    #<EarliestAvailability>
    #  <TimepointType>Immediately</TimepointType>
    #</EarliestAvailability>

    class InventorySupplyMember < Node
      xml_name "member"
      xml_reader :seller_sku, :from => 'SellerSKU'
      xml_reader :asin, :from => 'ASIN'
      xml_reader :total_supply_quantity, :as => Integer
      xml_reader :fnsku, :from => 'FNSKU'
      xml_reader :condition
      xml_reader :in_stock_supply_quantity, :as => Integer
      xml_reader :supply_detail, :as => SupplyDetail, :in=>'SupplyDetail', :from=>'member'
      xml_reader :earliest_availability, :in => 'EarliestAvailability', :from=>'TimepointType'
    end

    class InventorySupplyList < Node
      xml_name "InventorySupplyList"
      xml_reader :members, :as => [InventorySupplyMember], :from=>'member'
    end

    class ListInventorySupplyResponse < Response
      xml_name "ListInventorySupplyResponse"
      result = "ListInventorySupplyResult"

      xml_reader :next_token, :in => result
      xml_reader :request_id, :in => "ResponseMetadata"
      xml_reader :inventory_supply_list, :as=>InventorySupplyList, :in=>result
    end

    class ListInventorySupplyByNextTokenResponse < Response
      xml_name "ListInventorySupplyByNextTokenResponse"
      result = "ListInventorySupplyByNextTokenResult"

      xml_reader :next_token, :in => result
      xml_reader :request_id, :in => "ResponseMetadata"
      xml_reader :inventory_supply_list, :as=>InventorySupplyList, :in=>result
    end

  end
end
