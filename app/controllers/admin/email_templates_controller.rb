class Admin::EmailTemplatesController < Admin::BaseController
  before_filter :load_email_template, only: [:edit, :update]

  def edit
  end

  def update
    if params[:submit]
      @email_template.update_attributes(email_template_params)
      redirect_to admin_email_templates_path, notice: "#{@email_template} was updated successfully."
    else
      @email_template.assign_attributes(params[:email_template])
      @email_template.valid?
      render :edit
    end
  end

  private

  def load_email_template
    @email_template = EmailTemplate.find(params[:id])
  end

  def email_template_params
    params.require(:email_template).permit(:subject, :description, :body, :category)
  end
end
