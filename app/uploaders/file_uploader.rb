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
    result
  end

  def generate_location(io, context)
    Rails.logger.info "FileUploader#generate_location"
    year  = Time.now.strftime("%Y")
    month = Time.now.strftime("%m")
    original_filename = context[:metadata]["filename"]

    # the default unique identifier
    name = "#{SecureRandom.hex[0..6]}-#{original_filename}"

    [year, month, name].compact.join("/")
  end
end
