class Cas::Api::FilesController < Cas::ApplicationController
  skip_before_action :authenticate_user!

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
      file: metadata.to_json,
      attachable: attachable_record
    )
    file.save
    render json: {
      data: {
        id: file.id.to_s,
        type: "media-files",
        attributes: {
          url: file.url(use_cdn: false).to_s
        }
      }
    }
  end

  #def update
  #  file = ::Cas::MediaFile.find(params[:id])

  #  if file.update(resource_params)
  #    response = {
  #      data: {
  #        id: file.id,
  #        type: "media-files",
  #        attributes: {
  #          url: file.url(use_cdn: false).to_s,
  #          cover: file.cover?
  #        }
  #      }
  #    }
  #    render json: response
  #  else
  #    render json: { errors: file.errors.full_messages.join }, status: 400
  #  end
  #end

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
            :id,
            :storage,
            metadata: [:size, :filename, :mime_type, 'mime-type']
          ]
        ],
        relationships: [
          attachable: [
            data: [:id, :type]
          ]
        ]
      )

    if r[:attributes][:metadata].present?
      if r[:attributes][:metadata][:metadata][:mime_type].blank?
        r[:attributes][:metadata][:metadata][:mime_type] = r[:attributes][:metadata][:metadata][:"mime-type"]
      end
      r[:attributes][:metadata][:metadata].delete(:"mime-type")
    end
    r
  end

  def attachable_record
    rel = resource_params[:relationships]
    if rel.present?
      attachable = resource_params[:relationships][:attachable][:data]
      if attachable[:type] == 'contents'
        @attachable ||= Cas::Content.find(attachable[:id])
      end
    end
  end
end
