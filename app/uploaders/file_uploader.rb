class ::FileUploader < Shrine

  Attacher.derivatives do |original|
    result = {
    }

    if context[:record].media_type == 'image'
      result = Cas::RemoteCallbacks.callbacks[:uploaded_image_versions].call(original)
    end

    Rails.logger.info "FileUploader, versions: [#{result.keys.join(", ")}]"
    result
  end

  def generate_location(io, context)
    year  = Time.now.strftime("%Y")
    month = Time.now.strftime("%m")
    original_filename = context[:metadata]["filename"]

    # the default unique identifier
    name = "#{SecureRandom.hex[0..6]}-#{original_filename}"

    [year, month, name].compact.join("/")
  end
end
