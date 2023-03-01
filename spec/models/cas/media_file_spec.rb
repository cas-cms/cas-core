require 'rails_helper'

module Cas
  RSpec.describe MediaFile, type: :model do
    describe "callbacks" do
      describe "setting media_type" do
        context 'when image' do
          let(:mime_type) { 'image/jpg/' }

          it 'is set upon validation' do
            file = described_class.new(mime_type: mime_type)
            file.valid?
            expect(file.media_type).to eq 'image'
          end
        end

        context 'when not image' do
          let(:mime_type) { 'document/pdf/' }

          it 'sets media type as attachment' do
            file = described_class.new(mime_type: mime_type)
            file.valid?
            expect(file.media_type).to eq 'attachment'
          end
        end
      end

      describe 'unique cover per content' do
        let(:content) { create(:content) }
        let!(:file1) { create(:file, attachable: content, cover: true) }
        let!(:file2) { create(:file, attachable: content, cover: false) }
        let!(:file3) { create(:file, attachable: content, cover: false) }
        let!(:file4) { create(:file, cover: true) }

        context 'when settings image as cover' do
          it 'sets all other covers from the same attachable as false' do
            file3.update!(cover: true)
            expect(file1.reload).to_not be_cover
            expect(file2.reload).to_not be_cover
            expect(file3.reload).to be_cover
            expect(file4.reload).to be_cover
          end
        end

        context 'when setting first image' do
          it 'sets it as cover' do
            existing_content_file  = create(:file, attachable: content)
            first_file_for_content = create(:file)

            expect(existing_content_file).to_not be_cover
            expect(first_file_for_content).to be_cover
          end
        end

        context 'when creating attachment' do
          it 'does not set as cover' do
            existing_content_file  = create(:file, :attachment, attachable: content)
            first_file_for_content = create(:file, :attachment)

            expect(existing_content_file).to_not be_cover
            expect(first_file_for_content).to_not be_cover
          end
        end
      end
    end

    describe "#site" do
      let(:site) { create(:site) }
      let(:section) { create(:section, site: site) }
      let(:content) { create(:content, section: section) }

      it 'returns the attachable site' do
        file = create(:file, attachable: content)
        expect(file.site).to eq site
      end
    end

    describe '#url' do
      before do
        allow(ENV).to receive(:fetch).with("CDN_HOST", nil) { "http://cdn" }
      end

      context 'when S3' do
        subject { build(:file) }

        let(:attacher_url) { "/cache/" + JSON.parse(subject.file_data).fetch("id") }

        before do
          allow(ENV).to receive(:fetch).with("S3_BUCKET") { "com.bucket" }
          allow(ENV).to receive(:fetch).with("S3_REGION", "s3") { "us-east-1" }
          allow(ENV).to receive(:fetch).with("AWS_EC2_METADATA_DISABLED", "false") { "false" }

          # This is not ideal because we're stubbing internal methods from a
          # gem which we don't control. Unfortunately, we use S3 in production
          # but in tests we don't, and Shrine returns different objects with
          # different methods when we call `file_url`, which is really an
          # alias to Shrine::Attacher#url, but the problem is that it uses a
          # `storage` object to figure out that `url`, and in tests it's not S3,
          # so it just returns `nil`.
          #
          # This will bypass that.
          stub_attacher_url(subject: subject, attacher_url: attacher_url)
        end

        context 'when no CDN should be used' do
          context 'when path is present' do
            subject { build(:file, :with_path) }

            it 'returns full URL' do
              expect(subject.url(version: "original", use_cdn: false)).to match "https://s3-us-east-1.amazonaws.com/com.bucket/fc8ff0798fee2a486cf335de777f3a0d.jpg"
            end
          end

          context 'when no path is present' do
            it 'returns full URL' do
              # In test env, Shrine is not configured with S3 so it's not
              # returning the host here, but when S3 is configured it is.
              expect(subject.url(version: "original", use_cdn: false))
                .to match "/cache/fc8ff0798fee2a486cf335de777f3a0d.jpg"
            end
          end
        end

        context 'when no CDN exists' do
          before do
            allow(ENV).to receive(:fetch).with("CDN_HOST", nil) { "" }
          end

          it 'returns S3 url' do
            expect(subject.url(version: "original")).to match "/cache/fc8ff0798fee2a486cf335de777f3a0d.jpg"
          end
        end

        context 'when CDN exists' do
          before do
            allow(ENV).to receive(:fetch).with("CDN_HOST", nil) { "http://cdn" }
          end

          context 'when uploaded with shrine' do
            let(:attacher_url) { "http://cdn/cache/fc8ff0798fee2a486cf335de777f3a0d.jpg" }

            it 'returns shrine URL with CDN as host' do
              expect(subject.url(version: :original))
                .to match "http://cdn/cache/fc8ff0798fee2a486cf335de777f3a0d.jpg"
            end
          end

          context 'when only path is present' do
            let(:attacher_url) { nil }

            subject { build(:file, file_data: "{}", path: 'custom-path') }

            it 'returns CDN host + path' do
              expect(subject.url(version: :original)).to eq "http://cdn/custom-path"
            end
          end
        end
      end
    end
  end
end
