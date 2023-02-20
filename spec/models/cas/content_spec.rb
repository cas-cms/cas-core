require 'rails_helper'

module Cas
  RSpec.describe Content, type: :model do
    describe "callbacks" do

      describe 'tags_cache' do
        subject { create(:content) }

        it 'saves the tags in tags_cache' do
          expect(subject.tags_cache).to be_blank
          subject.tag_list = "tag1, tag2"
          subject.save
          subject.reload
          expect(subject.tags_cache).to eq "tag1, tag2"
        end

        it 'saves the category name in tags_cache' do
          expect(subject.tags_cache).to be_blank
          subject.tag_list = "tag1, tag2"
          subject.category = create(:category, name: 'category_name')
          subject.save
          subject.reload
          expect(subject.tags_cache).to eq "tag1, tag2, category_name"
        end

        it 'saves tags with spaces' do
          expect(subject.tags_cache).to be_blank
          subject.tag_list = "tag one, tag two, tag3"
          subject.save!
          subject.reload
          expect(subject.tags_cache).to eq "tag one, tag two, tag3"
        end
      end

      describe "published_at" do
        subject { build(:content, published_at: published_at, published: published) }

        before do
          subject.valid?
        end

        context 'when published_at is nil' do
          let(:published_at) { nil }

          context 'when published' do
            let(:published) { true }

            it 'sets published_at automatically' do
              expect(subject.published_at).to be_present
            end
          end

          context 'when not published' do
            let(:published) { false }

            it 'does not set published_at automatically' do
              expect(subject.published_at).to be_blank
            end
          end
        end

        context 'when published_at is present' do
          let(:published_at) { 3.days.ago }

          context 'when published' do
            let(:published) { true }

            it 'sets published_at automatically' do
              expect(subject.published_at).to eq published_at
            end
          end

          context 'when not published' do
            let(:published) { false }

            it 'does not set published_at automatically' do
              expect(subject.published_at).to eq published_at
            end
          end
        end
      end
    end
  end
end
