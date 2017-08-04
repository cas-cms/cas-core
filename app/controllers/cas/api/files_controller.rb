class Cas::Api::FilesController < Cas::ApplicationController
  skip_before_action :authenticate_user!

  def create
    if ENV.fetch("S3_BUCKET")
      service = "s3"
    end
    metadata = resource_params[:attributes][:metadata]
    file = ::Cas::MediaFile.new(
      service: service,
      size: metadata[:original][:metadata][:size].to_i,
      original_name: metadata[:original][:metadata][:filename],
      mime_type: metadata[:original][:metadata][:mime_type],
      file: metadata.to_json,
      attachable: attachable_record
    )
    file.save
    Cas::RemoteCallbacks.callbacks[:after_file_upload].call(file)
    render json: {
      data: {
        id: file.id.to_s,
        type: "media-files",
        attributes: {
          url: file.url(version: :original, use_cdn: false).to_s
        }
      }
    }
  end

  def destroy
    files = ::Cas::MediaFile.where(id: params[:id].split(","))
    success = nil
    ActiveRecord::Base.transaction do
      success = files.each(&:destroy).all?
    end

    if success
      render json: {}, status: 204
    else
      render json: {}, status: 400
    end
  end

  private

  def resource_params
    r = params
      .require(:data)
      .permit(
        attributes: [
          :cover,
          metadata: [
            original: [
              :id,
              :storage,
              metadata: [:size, :filename, :mime_type, 'mime-type']
            ]
          ]
        ],
        relationships: [
          attachable: [
            data: [:id, :type]
          ]
        ]
      )

    if r[:attributes][:metadata].present?
      if r[:attributes][:metadata][:original][:metadata][:mime_type].blank?
        r[:attributes][:metadata][:original][:metadata][:mime_type] = r[:attributes][:metadata][:original][:metadata][:"mime-type"]
      end
      r[:attributes][:metadata][:original][:metadata].delete(:"mime-type")
    end
    r
  end

  def attachable_record
    rel = resource_params[:relationships]
    if rel.present?
      attachable = resource_params[:relationships][:attachable][:data]
      if attachable[:type] == 'contents' && attachable[:id].present?
        @attachable ||= Cas::Content.find(attachable[:id])
      end
    end
  end
end
