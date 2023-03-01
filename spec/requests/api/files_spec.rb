require "rails_helper"

RSpec.describe "API /media_files" do
  let(:content) { create(:content) }
  let!(:site) { create(:site) }

  before do
    sign_in
  end

  describe 'POST /api/media_files' do
    let(:payload) do
      {
        data: {
          attributes: {
            service: "s3",
            media_type: 'custom-media-type',
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

    context 'when relationship is passed in' do
      before do
        stub_any_media_url(url: "/cache/filename1.jpg")
      end

      it 'creates a new file' do
        expect(Cas::MediaFile.count).to eq 0
        post "/admin/api/files", params: payload
        expect(Cas::MediaFile.count).to eq 1

        new_file = Cas::MediaFile.first
        expect(new_file.service).to eq "s3"
        expect(new_file.size).to eq 1
        expect(new_file.original_name).to eq "file1.jpg"
        expect(new_file.mime_type).to eq "image/jpeg"
        expect(new_file.media_type).to eq "custom-media-type"
        expect(new_file.attachable).to eq content
        expect(new_file.file_data).to eq({
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
            id: new_file.id.to_s,
            type: "media-files",
            attributes: {
              url: "/cache/filename1.jpg",
              "original-name": "file1.jpg"
            }
          }
        }.deep_stringify_keys)
      end
    end

    context 'when no relationship is passed in' do
      it 'creates the file without attachable' do
        payload[:data][:relationships][:attachable][:data][:id] = ""
        payload[:data][:relationships][:attachable][:data][:type] = "contents"
        expect(Cas::MediaFile.count).to eq 0
        post "/admin/api/files", params: payload
        expect(Cas::MediaFile.count).to eq 1

        new_file = Cas::MediaFile.last
        expect(new_file.attachable).to eq nil
      end
    end

    it "calls remote callbacks" do
      called_callback = false
      Cas::RemoteCallbacks.callbacks = {
        after_file_upload: ->(file) {
          called_callback = true
          expect(file.original_name).to eq "file1.jpg"
        }
      }

      post "/admin/api/files", params: payload

      expect(called_callback).to eq true
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
