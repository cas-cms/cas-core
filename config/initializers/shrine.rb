require 'shrine'

Shrine.plugin :activerecord
Shrine.plugin :presign_endpoint
Shrine.plugin :backgrounding

pp "Rails.env: #{Rails.env.inspect}"

if Rails.env.test?
  s3_options = {
    access_key_id:     'access_key_id',
    secret_access_key: 'secret_access_key',
    region:            'us-east-1',
    bucket:            'com.bucket'
  }
  require "shrine/storage/file_system"

  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("tmp/uploads", prefix: "cache"),
    store: Shrine::Storage::FileSystem.new("tmp/uploads", prefix: "store")
  }
else
  if ENV["S3_ACCESS_KEY_ID"].blank?
    msg = "You need to configure S3 credentials. See the README.md for more details."
    puts msg
    Rails.logger.error msg
  end

  s3_options = {
    access_key_id:     ENV.fetch("S3_ACCESS_KEY_ID"),
    secret_access_key: ENV.fetch("S3_SECRET_ACCESS_KEY"),
    region:            ENV.fetch("S3_REGION"),
    bucket:            ENV.fetch("S3_BUCKET"),
  }

  require "shrine/storage/s3"
  config = Cas::Config.new.uploads
  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: config[:cache_directory_prefix], **s3_options),
    store: Shrine::Storage::S3.new(prefix: config[:store_directory_prefix], **s3_options),
  }
end

Shrine::Attacher.promote do |data|
  Rails.logger.info "Shrine promoting file scheduled"
  ::Cas::Images::PromoteJob.perform_async(data)
end

Shrine::Attacher.delete do |data|
  Rails.logger.info "Shrine deleting file scheduled"
  ::Cas::Images::DeleteJob.perform_async(data)
end
