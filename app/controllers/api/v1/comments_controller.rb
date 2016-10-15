class Api::V1::CommentsController < Api::V1::BaseController
  def create
    opportunity = Opportunity.find(params[:opportunity_id])
    raise "Access denied" unless opportunity.buyer_id == current_company.id
    comment = opportunity.comments.create(:body => params[:comment][:body], :commenter => current_company, commenter_name: current_company.name)
    respond_with_namespace(opportunity, comment)
  end
end
