class ActorSerializer < ActiveModel::Serializer
  attributes :_id, :name, :abbreviated_name, :logo_url, :contact_name, :contact_phone, :email, :tpa, :recommend

  def logo_url
    Cloudinary::Utils.cloudinary_url(object.logo_id, width: 180, crop: :scale, format: 'png')
  end

  def recommend
    object.recent_won_bid_amount <= 2000
  end
end
