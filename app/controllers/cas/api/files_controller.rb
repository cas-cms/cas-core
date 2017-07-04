class Cas::Api::FilesController < Cas::ApplicationController
  def create
    if ENV.fetch("S3_BUCKET")
      service = "s3"
    end
    metadata = resource_params[:attributes][:metadata]
    file = ::Cas::MediaFile.new(
      service: service,
      size: metadata[:metadata][:size].to_i,
      original_name: metadata[:metadata][:filename],
      mime_type: metadata[:metadata][:mime_type],
      file: metadata.to_json
    )
    file.save
    render json: {
      data: {
        id: file.id.to_s,
        attributes: {
          url: file.url(use_cdn: false).to_s
        }
      }
    }
  end

  def destroy
    file = ::MediaFile.find(params[:id])
    if file.ownerable == @client
      if file.destroy
        render json: {}, status: 204
      else
        render json: {}, status: 400
      end
    elsif file.ownerable.blank?
      render json: {}, status: 204
    else
      render json: {}, status: 404
    end
  end

  private

  def resource_params
    r = params
      .require(:data)
      .permit(
        attributes: [
          metadata: [
            :id,
            :storage,
            metadata: [:size, :filename, :mime_type, 'mime-type']
          ]
        ]
      )

    if r[:attributes][:metadata][:metadata][:mime_type].blank?
      r[:attributes][:metadata][:metadata][:mime_type] = r[:attributes][:metadata][:metadata][:"mime-type"]
    end
    r[:attributes][:metadata][:metadata].delete(:"mime-type")
    r
  end
end
