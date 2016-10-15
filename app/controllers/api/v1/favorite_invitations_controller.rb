class Api::V1::FavoriteInvitationsController < Api::V1::BaseController
  skip_before_filter :restrict_access, only: :show

  def show
    favorite_invitation = FavoriteInvitation.pending.find(params[:id])

    respond_with_namespace(favorite_invitation)
  end

  def create
    @favorite_invitation = FavoriteInvitation.new(params[:favorite_invitation])
    @favorite_invitation.buyer = current_company
    if @favorite_invitation.save
      Notifier.delay.send_unknown_favorite_invitation(@favorite_invitation.id)
    end

    respond_with_namespace @favorite_invitation
  end
end
