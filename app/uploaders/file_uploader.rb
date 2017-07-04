class ::FileUploader < Shrine
  def generate_location(io, context)
    year  = Time.now.strftime("%Y")
    month = Time.now.strftime("%m")
    name  = super # the default unique identifier

    ["uploads", year, month, name].compact.join("/")
  end
end
