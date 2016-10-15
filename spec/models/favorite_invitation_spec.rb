require 'spec_helper'

describe FavoriteInvitation do
  it "should be pending by default" do
    FavoriteInvitation.new.should be_pending
  end

  describe "#accpet!" do
    it "should mark it as accepted" do
      invitation = FactoryGirl.create(:favorite_invitation)
      supplier = FactoryGirl.create(:company, created_from_invitation_id: invitation.id)

      # invitation.reload doesn't work, that's why we have to get it from supplier
      invitation = supplier.created_from_invitation
      invitation.accept!

      invitation.should be_accepted
      invitation.should_not be_pending
    end
  end
end

