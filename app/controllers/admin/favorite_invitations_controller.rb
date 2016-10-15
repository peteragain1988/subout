class Admin::FavoriteInvitationsController < Admin::BaseController
  def index
    @invitations = FavoriteInvitation.recent
  end

  def resend_invitation
    invitation = FavoriteInvitation.pending.find(params[:id])
    Notifier.delay.send_unknown_favorite_invitation(invitation.id)

    redirect_to admin_favorite_invitations_path, notice: "Resent invitation successfully"
  end
end
