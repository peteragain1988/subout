class Api::V1::CompaniesController < Api::V1::BaseController
  skip_before_filter :restrict_access, only: :create
  skip_before_filter :restrict_ghost_user, only: [:create, :update_agreement]
  #serialization_scope :current_company

  def index
    companies = Company.companies_for(current_company)
    render json: companies, each_serializer: ActorSerializer
  end

  def show
    @company = Company.find(params[:id])
    @serializer = CompanySerializer.new(@company, :scope => current_company)
    render json: @serializer
  end

  def search
    @companies = Company.search(params[:query]).limit(20)
    render json: @companies
  end

  def update
    company_params = params.require(:company).permit(:abbreviated_name, :dot_number, :insurance, :logo_id, :since, :owner, :contact_name, :contact_phone, :email, :website, :cell_phone,
        :address_line1, :address_line2, :city, :state, :country, :zip_code, :payment_methods, :notification_email, :notification_type, :poster_message, :regions, :fleet, :fleet_size, :has_ada_vehicles, :vehicle_types=>[], :notification_items=>[])

    company_params = company_params.merge(vehicle_types: []) if company_params["vehicle_types"].blank?
    company_params = company_params.merge(notification_items: []) if company_params["notification_items"].blank?
    
    current_company.update_attributes(company_params)
    respond_with_serializer()
  end

  def create
    chargify_id = params[:company][:chargify_id]
    subscription = nil

    if chargify_id.present?
      subscription = GatewaySubscription.where(subscription_id: chargify_id).first
    end

    company = Company.new(params.require(:company).permit(:name, :email, :abbreviated_name, :dot_number, :insurance, :logo_id, :since, :owner, :contact_name, :contact_phone, :website, :fleet, :fleet_size, :has_ada_vehicles, :users_attributes=>[:email, :password, :password_confirmation]))

    if company.errors.any?
      render json: { errors: company.sign_up_errors }, status: 422
      return
    end

    company.created_from_subscription = subscription
    company.prelaunch = false

    if company.save
      @current_user = company.users.last
      respond_with_namespace(company)
    else
      render json: { errors: company.sign_up_errors }, status: 422
    end
  end

  def update_product
    if current_company.update_product!(params[:product])
      Notifier.delay.updated_product(current_company.id) if current_company.notification_items.include?("account-update-product")
      respond_with_serializer()
    else
      render json: { errors: current_company.errors.full_messages }, status: 423
    end
  end

  def update_agreement
    current_company.accept_tac!
    current_company.reload
    respond_with_serializer()
  end

  def update_regions
    if current_company.update_regions!(params[:company][:regions])
      respond_with_serializer()
    else
      render json: { errors: current_company.errors.full_messages }, status: 422
    end
  end

  def update_vehicles
    if current_company.update_vehicles!(params[:company][:vehicles])
      respond_with_serializer()
    else
      render json: { errors: current_company.errors.full_messages }, status: 422
    end
  end

  private

  def respond_with_serializer()
    current_company.reload
    @serializer = CompanySerializer.new(current_company, :scope => current_company)
    render json: @serializer
  end
end
