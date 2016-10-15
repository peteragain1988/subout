class GatewaySubscriptionSerializer < ActiveModel::Serializer
  attributes :_id, :created_at, :email, :first_name, :last_name, :organization, :has_valid_credit_card?, :subscription_id
end
