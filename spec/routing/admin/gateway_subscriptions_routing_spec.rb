require 'spec_helper'

describe Admin::GatewaySubscriptionsController do
  it { { get: '/admin/gateway_subscriptions' }.should route_to(controller: "admin/gateway_subscriptions", action: "index") }
  it { { put: '/admin/gateway_subscriptions/1/resend_invitation' }.should route_to(controller: "admin/gateway_subscriptions", action: "resend_invitation", id: "1") }
  it { { get: '/admin/gateway_subscriptions/1/edit' }.should route_to(controller: "admin/gateway_subscriptions", action: "edit", id: "1") }
end
