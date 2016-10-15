unless Rails.env.test?
  s3_secrets = Rails.application.secrets[:s3]
  if Rails.env.test? or Rails.env.cucumber?
    CarrierWave.configure do |config|
      config.storage = :file
      config.enable_processing = false
    end
  elsif s3_secrets && s3_secrets["access_key_id"].present?
    CarrierWave.configure do |config|
      config.storage = :fog
      config.fog_credentials = {
        :provider               => 'AWS',
        :aws_access_key_id      => s3_secrets["access_key_id"],
        :aws_secret_access_key  => s3_secrets["secret_access_key"]
      }
      config.fog_directory  = s3_secrets["bucket"]
    end
  else
    CarrierWave.configure do |config|
      config.storage = :file
    end
  end
end