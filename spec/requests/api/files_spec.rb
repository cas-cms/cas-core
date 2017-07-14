require "rails_helper"

RSpec.describe "API /media_files" do
  let(:content) { create(:content) }

  before do
    sign_in
  end

  describe 'POST /api/media_files' do
    let(:payload) do
      {
        data: {
          attributes: {
            service: "s3",
            metadata: {
              id: "filename1.jpg",
              storage: "cache",
              metadata: {
                size: 1,
                filename: "file1.jpg",
                "mime-type": "image/jpeg",
              }
            }
          },
          relationships: {
            attachable: {
              data: {
                id: content.id,
                type: "contents"
              }
            }
          }
        }
      }
    end

    it 'creates a new file' do
      expect(Cas::MediaFile.count).to eq 0
      post "/admin/api/files", params: payload
      expect(Cas::MediaFile.count).to eq 1
      expect(Cas::MediaFile.first.service).to eq "s3"
      expect(Cas::MediaFile.first.size).to eq 1
      expect(Cas::MediaFile.first.original_name).to eq "file1.jpg"
      expect(Cas::MediaFile.first.mime_type).to eq "image/jpeg"
      expect(Cas::MediaFile.first.media_type).to eq "image"
      expect(Cas::MediaFile.first.attachable).to eq content
      expect(Cas::MediaFile.first.file_data).to eq({
        id: "filename1.jpg",
        storage: "cache",
        metadata: {
          size: "1",
          filename: "file1.jpg",
          mime_type: "image/jpeg",
        }
      }.to_json)

      expect(json).to eq({
        data: {
          id: Cas::MediaFile.last.id.to_s,
          type: "media-files",
          attributes: {
            url: "https://s3.amazonaws.com/com.bucket/cache/filename1.jpg"
          }
        }
      }.deep_stringify_keys)
    end
  end

  describe 'DELETE /api/files/:id' do
    let!(:file1) { create(:file) }
    let!(:file2) { create(:file) }
    let!(:file3) { create(:file) }

    it 'deletes multiple files' do
      expect(Cas::MediaFile.count).to eq 3
      ids = [file1, file2, file3].map(&:id)
      delete "/admin/api/files/#{ids.join(",")}", params: {}
      expect(Cas::MediaFile.count).to eq 0
    end
  end
end

