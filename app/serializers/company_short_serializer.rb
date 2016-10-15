class CompanyShortSerializer < ActiveModel::Serializer
  attributes :_id, :name, :email, :logo_id, :logo_url, :website, :notification_type,
    :fleet_size, :since, :owner, :contact_name, :tpa, :abbreviated_name, :contact_phone,
    :dot_number, :cell_phone, :notification_email

  def logo_url
    Cloudinary::Utils.cloudinary_url(object.logo_id, width: 200, crop: :scale, format: 'png')
  end
end
