class FileUploaderSignature
  def generate
    params_to_sign = {
      callback: "https://#{DEFAULT_HOST_WITH_PORT}/cloudinary_cors.html",
      timestamp: Time.now.to_i
    }

    signature = Cloudinary::Utils.api_sign_request(params_to_sign, "5csu53XTsHUJK8TtRET2jQpN-QA")

    params_to_sign.merge(api_key: "874422597178734", signature: signature)
  end
end
