class Admin::SettingsController < Admin::BaseController
  before_filter :load_setting, only: [:edit, :update]

  def edit
  end

  def update
    if @setting.update_attributes(params.require(:setting).permit(:value))
      redirect_to admin_settings_path, notice: "#{@setting} was updated successfully."
    else
      render :edit
    end
  end

  private

  def load_setting
    @setting = Setting.find(params[:id])
  end
end
