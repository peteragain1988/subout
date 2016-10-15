class Admin::GatewaySubscriptionsController < Admin::BaseController
  def index
    @subscriptions = GatewaySubscription.by_category(params[:category]).recent
    @subscriptions = @subscriptions.full_text_search(params[:search]) unless params[:search].blank?
    @subscriptions = @subscriptions.page(params[:page]).per(20)

    respond_to do |format|
      format.html
      format.csv { send_data GatewaySubscription.recent.to_csv }
    end
  end

  def resend_invitation
    subscription = GatewaySubscription.pending.find(params[:id])
    Notifier.delay.subscription_confirmation(subscription.id)

    redirect_to admin_gateway_subscriptions_path, notice: "Resent invitation successfully"
  end

  def edit
    @subscription = GatewaySubscription.find(params[:id])
  end

  def update
    @subscription = GatewaySubscription.find(params[:id])
    @subscription.update_attributes(params.require(:gateway_subscription).permit(:email, :product_handle))
    @subscription.update_product!(params[:gateway_subscription][:product_handle])

    redirect_to edit_admin_gateway_subscription_path(@subscription), notice: "Subscription updated"
  end
end
