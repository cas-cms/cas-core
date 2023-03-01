module ShrineStubbing
  # This is not ideal because we're stubbing internal methods from a
  # gem which we don't control. Unfortunately, we use S3 in production
  # but in tests we don't, and Shrine returns different objects with
  # different methods when we call `file_url`, which is really an
  # alias to Shrine::Attacher#url, but the problem is that it uses a
  # `storage` object to figure out that `url`, and in tests it's not S3,
  # so it just returns `nil`.
  #
  # This will bypass that.
  def stub_attacher_url(subject: nil, attacher_url:)
    require "shrine/storage/s3"
    allow(subject)
      .to receive(:file_attacher)
      .and_return(
        instance_double(Shrine::Attacher, url: attacher_url)
      )
  end

  def stub_any_media_url(url:)
    require "shrine/storage/s3"
    allow_any_instance_of(Cas::MediaFile)
      .to receive(:url)
      .and_return(url)
  end
end
