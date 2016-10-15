require './config/environment.rb'


class ChargifyUtils < Thor
  desc "copy_products", "Copy production chargify products to given chargify site"
  def copy_products(target)
    return if target == "subout" # never change production site data

    change_site("subout")
    product_families = []

    Chargify::ProductFamily.find(:all).each do |product_family|
      product_family_attributes = product_family.attributes
      product_family_attributes[:products] = []
      product_family.products.each do |product|
        product_attributes = product.attributes
        product_family_attributes[:products] << product_attributes
      end

      product_family_attributes[:components] = []
      product_family.components.each do |component|
        component_attributes = component.attributes
        product_family_attributes[:components] << component_attributes
      end

      product_families << product_family_attributes
    end

    change_site(target)
    product_families.each do |product_family|
      created_product_family = Chargify::ProductFamily.create(product_family)
      product_family[:products].each do |product|
        product[:product_family_id] = created_product_family.id
        Chargify::Product.create(product)
      end

      product_family[:components].each do |component|
        component[:product_family_id] = created_product_family.id
        component[:component_type] = component[:kind] + "s"
        Chargify::Component.create(component.slice("component_type", "name", "unit_name", "unit_price", "pricing_scheme", "product_family_id"))
      end
    end
  end

  private

  def change_site(subdomain)
    Chargify.configure { |c| c.site = "https://#{subdomain}.chargify.com" }
  end
end

