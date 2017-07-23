class ::FileUploader < Shrine
  plugin :versions
  plugin :processing

  process(:store) do |io, context|
    {original: io}
  end

  def generate_location(io, context)
    Rails.logger.info "FileUploader#generate_location"
    year  = Time.now.strftime("%Y")
    month = Time.now.strftime("%m")
    name  = super # the default unique identifier

    [year, month, name].compact.join("/")
  end
end
