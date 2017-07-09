require 'rails_helper'

module Cas
  RSpec.describe MediaFile, type: :model do
    describe "callbacks" do
      describe "setting media_type" do
        it 'is set upon validation' do
          file = described_class.new(mime_type: 'image/jpg/')
          file.valid?
          expect(file.media_type).to eq 'image'
        end
      end
    end

    describe '#url' do
      before do
        allow(ENV).to receive(:fetch).with("CDN_HOST", nil) { "http://cdn/" }
      end

      context 'when S3' do
        subject { build(:file) }

        before do
          allow(ENV).to receive(:fetch).with("S3_BUCKET") { "com.bucket" }
          allow(ENV).to receive(:fetch).with("S3_REGION", "s3") { "us-east-1" }
        end

        context 'when no CDN should be used' do
          context 'when path is present' do
            subject { build(:file, :with_path) }

            it 'returns full URL' do
              expect(subject.url(use_cdn: false)).to match "https://s3-us-east-1.amazonaws.com/com.bucket/fc8ff0798fee2a486cf335de777f3a0d.jpg"
            end
          end

          context 'when no path is present' do
            it 'returns full URL' do
              expect(subject.url(use_cdn: false)).to match "https://s3.amazonaws.com/com.bucket/cache/fc8ff0798fee2a486cf335de777f3a0d.jpg"
            end
          end
        end

        context 'when no CDN exists' do
          before do
            allow(ENV).to receive(:fetch).with("CDN_HOST", nil) { "" }
          end

          it 'returns S3 url' do
            expect(subject.url).to match "https://s3.amazonaws.com/com.bucket/cache/fc8ff0798fee2a486cf335de777f3a0d.jpg"
          end
        end

        context 'when CDN exists' do
          before do
            allow(ENV).to receive(:fetch).with("CDN_HOST", nil) { "http://cdn/" }
          end

          context 'when uploaded with shrine' do
            it 'returns shrine URL with CDN as host' do
              expect(subject.url).to match "http://cdn/cache/fc8ff0798fee2a486cf335de777f3a0d.jpg"
            end
          end

          context 'when only path is present' do
            subject { build(:file, file_data: "{}", path: 'custom-path') }

            it 'returns CDN host + path' do
              expect(subject.url).to eq "http://cdn/custom-path"
            end
          end
        end
      end
    end
  end
end
