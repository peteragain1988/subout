require 'spec_helper'

describe Admin::FavoriteInvitationsController do
  it { { get: '/admin/favorite_invitations' }.should route_to(controller: "admin/favorite_invitations", action: "index") }
  it { { put: '/admin/favorite_invitations/1/resend_invitation' }.should route_to(controller: "admin/favorite_invitations", action: "resend_invitation", id: "1") }
end
