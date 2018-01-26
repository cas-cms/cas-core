class Cas::FileUploadsController < Cas::ApplicationController
  skip_before_action :authenticate_person!
  skip_before_filter :verify_authenticity_token

  def create
    file = params.fetch(:file)
    uploader = ::FileUploader.new(:store)
    uploaded_file = uploader.upload(file)
    url = uploaded_file.url(public: true, host: ENV.fetch("CDN_HOST", nil))
    render json: {
      location: url
    }
  end
end
