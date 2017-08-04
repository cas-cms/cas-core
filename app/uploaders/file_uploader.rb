class ::FileUploader < Shrine
  plugin :versions
  plugin :processing

  process(:store) do |io, context|
    result = Cas::RemoteCallbacks.callbacks[:uploaded_image_versions].call(io, context)
    original = (io.respond_to?(:[]) && io[:original]) ? io[:original] : io
    result = result.merge(original: original) unless result.keys.include?(:original)
    result
  end

  def generate_location(io, context)
    Rails.logger.info "FileUploader#generate_location"
    year  = Time.now.strftime("%Y")
    month = Time.now.strftime("%m")
    name  = super # the default unique identifier

    [year, month, name].compact.join("/")
  end
end
