require 'spec_helper'

describe Admin::FavoriteInvitationsController, "GET index" do
  it "renders a template" do
    http_login

    get :index

    response.status.should == 200
    response.should render_template("index")
  end
end

describe Admin::FavoriteInvitationsController, "PUT resend_invitation" do
  let!(:invitation) { FactoryGirl.create(:favorite_invitation) }

  it "sends invitation again" do
    http_login

    Notifier.should_receive(:send_unknown_favorite_invitation).with(invitation.id)

    put :resend_invitation, id: invitation.id
    response.should redirect_to(admin_favorite_invitations_path)
  end
end
