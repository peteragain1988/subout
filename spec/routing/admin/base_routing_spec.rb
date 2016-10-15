require 'spec_helper'

describe Admin::BaseController do
  it { { get: '/admin' }.should route_to(controller: "admin/base", action: "index") }
end
