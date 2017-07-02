require 'shrine'

if Rails.env.test?
  require "shrine/storage/file_system"

  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("tmp", prefix: "uploads/cache"),
    store: Shrine::Storage::FileSystem.new("tmp", prefix: "uploads/store")
  }
else
  require "shrine/storage/s3"

  s3_options = {
    access_key_id:     ENV.fetch("S3_ACCESS_KEY_ID"),
    secret_access_key: ENV.fetch("S3_SECRET_ACCESS_KEY"),
    region:            ENV.fetch("S3_REGION"),
    bucket:            ENV.fetch("S3_BUCKET"),
  }
  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: "cache", **s3_options),
    store: Shrine::Storage::S3.new(prefix: "store", **s3_options),
  }
end

Shrine.plugin :activerecord
Shrine.plugin :direct_upload
Shrine.plugin :backgrounding

Shrine::Attacher.promote do |data|
  Rails.logger.info "Shrine promoting"
  puts "Shrine promoting"
  ::Cas::Images::PromoteJob.perform_async(data)
end

Shrine::Attacher.delete do |data|
  ::Cas::Images::DeleteJob.perform_async(data)
end

class FineUploaderResponse
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    if status == 200
      data = JSON.parse(body[0])
      data['success'] = 'true'
      body[0] = data.to_json
      headers['Content-Length'] = body[0].bytesize
    end

    [status, headers, body]
  end
end

Shrine::UploadEndpoint.use FineUploaderResponse
