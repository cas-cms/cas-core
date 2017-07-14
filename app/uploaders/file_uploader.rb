class ::FileUploader < Shrine
  def generate_location(io, context)
    Rails.logger.info "FileUploader#generate_location"
    year  = Time.now.strftime("%Y")
    month = Time.now.strftime("%m")
    name  = super # the default unique identifier

    ["uploads", year, month, name].compact.join("/")
  end
end
