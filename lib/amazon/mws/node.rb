module Amazon
  module MWS

    class Node
      include ROXML
      xml_convention :camelcase

      def accessors
        roxml_references.map {|r| r.accessor}
      end

      # render a ROXML object as a normal hash, eliminating the @ and some unneeded admin fields
    	def as_hash
    		obj_hash = {}
    		self.instance_variables.each do |v|
    			m = v.to_s.sub('@','')
    			if m != 'roxml_references' && m!= 'promotion_ids'
    				obj_hash[m.to_sym] = self.instance_variable_get(v)
    			end
    		end
    		obj_hash
    	end
    	alias_method :to_hash, :as_hash

    end
  end
end
