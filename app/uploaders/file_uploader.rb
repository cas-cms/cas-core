class ::FileUploader < Shrine
  plugin :versions
  plugin :processing

  process(:store) do |io, context|
    result = {}
    if context[:record].media_type == 'image'
      result = Cas::RemoteCallbacks.callbacks[:uploaded_image_versions].call(io, context)
    end
    original = (io.respond_to?(:[]) && io[:original]) ? io[:original] : io
    result = result.merge(original: original) unless result.keys.include?(:original)
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
