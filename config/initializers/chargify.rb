require 'chargify_api_ares'

Chargify.configure do |c|
  c.subdomain = CHARGIFY_URI
  c.api_key   = CHARGIFY_TOKEN
end

module Chargify
  class Component < Base
    protected

    # Components are created in the scope of a ProductFamily with a component type, i.e. /product_families/nnn/component_type
    #
    # This alters the collection path such that it uses the product_family_id that is set on the
    # attributes.
    def create
      pfid = self.product_family_id
      comptype = self.component_type
      raise NoMethodError unless pfid && comptype

      connection.post("/product_families/#{pfid}/#{comptype}.#{self.class.format.extension}", encode, self.class.headers).tap do |response|
        self.id = id_from_response(response)
        load_attributes_from_response(response)
      end
    end

    def to_xml(options = {})
      options.merge!(:dasherize => false, :root => self.component_type.to_s.singularize)
      attributes.delete(:component_type)
      super
    end
  end
end
