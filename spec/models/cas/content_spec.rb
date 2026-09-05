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

    describe "publication date" do
      let!(:section) { create(:section) }
      let!(:published_last_week) { create(:content, section: section, created_at: 1.day.ago, published_at: 7.days.ago) }
      let!(:published_yesterday) { create(:content, section: section, created_at: 3.days.ago, published_at: 1.day.ago) }
      # published_at can be blank on rows that predate the column or were
      # published outside the model; update_columns skips the callback
      let!(:never_stamped) do
        create(:content, section: section, created_at: 4.days.ago).tap do |content|
          content.update_columns(published_at: nil)
        end
      end

      describe ".by_publication_date" do
        it "orders newest first, using created_at when published_at is blank" do
          expect(section.contents.by_publication_date).to eq [published_yesterday, never_stamped, published_last_week]
        end

        it "orders oldest first when asked" do
          expect(section.contents.by_publication_date(:asc)).to eq [published_last_week, never_stamped, published_yesterday]
        end

        it "breaks ties on created_at" do
          same_moment = create(:content, section: section, created_at: 2.days.ago, published_at: published_yesterday.published_at)

          expect(section.contents.by_publication_date.first(2)).to eq [same_moment, published_yesterday]
        end
      end

      describe ".published_since" do
        it "keeps contents published on or after the time, using created_at when published_at is blank" do
          expect(section.contents.published_since(5.days.ago)).to match_array [published_yesterday, never_stamped]
        end
      end

      describe "#publication_date" do
        it "is published_at when present" do
          expect(published_yesterday.publication_date).to eq published_yesterday.published_at
        end

        it "is created_at when published_at is blank" do
          expect(never_stamped.reload.publication_date).to eq never_stamped.created_at
        end
      end
    end
  end
end
