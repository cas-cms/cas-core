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

        it "rejects directions other than asc and desc" do
          expect { section.contents.by_publication_date(:descending) }.to raise_error(ArgumentError)
        end
      end

      describe ".publication_date_since" do
        # the scope filters on the date only; callers add .published themselves
        let!(:draft) { create(:content, section: section, published: false, created_at: 1.day.ago) }

        it "keeps contents whose publication date is on or after the time, using created_at when published_at is blank" do
          expect(section.contents.publication_date_since(5.days.ago)).to match_array [published_yesterday, never_stamped, draft]
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

    # The admin submits dates in parts, the way Rails' date and datetime
    # selects do. Brazil's daylight saving time started at local midnight until
    # 2019, so midnight did not exist on those days.
    describe "assigning a date from selects" do
      around do |example|
        Time.use_zone("Brasilia") { example.run }
      end

      def assign_parts(content, attribute, year, month, day, hour = nil, minute = nil)
        parts = {
          "#{attribute}(1i)" => year.to_s,
          "#{attribute}(2i)" => month.to_s,
          "#{attribute}(3i)" => day.to_s
        }
        parts["#{attribute}(4i)"] = hour.to_s if hour
        parts["#{attribute}(5i)"] = minute.to_s if minute
        content.assign_attributes(parts)
      end

      context "when only the day is picked" do
        it "keeps the stored time of day when the day is unchanged" do
          content = build(:content, published_at: Time.zone.local(2012, 5, 20, 9, 15))

          assign_parts(content, :published_at, 2012, 5, 20)

          expect(content.published_at).to eq Time.zone.local(2012, 5, 20, 9, 15)
        end

        it "uses the current time when the day is today" do
          content = build(:content, published_at: nil)
          today = Date.current

          assign_parts(content, :published_at, today.year, today.month, today.day)

          expect(content.published_at).to be_within(1.minute).of(Time.current)
        end

        it "is midnight of any other day" do
          content = build(:content, published_at: Time.zone.local(2012, 5, 20, 9, 15))

          assign_parts(content, :published_at, 2010, 3, 7)

          expect(content.published_at).to eq Time.zone.local(2010, 3, 7)
        end

        it "moves to the first existing hour on a day without a local midnight" do
          content = build(:content, published_at: nil)

          assign_parts(content, :published_at, 2010, 10, 17)

          expect(content.published_at).to eq Time.zone.local(2010, 10, 17, 1, 0)
        end

        it "applies the same rules to date" do
          content = build(:content, date: nil)

          assign_parts(content, :date, 2010, 10, 17)

          expect(content.date).to eq Time.zone.local(2010, 10, 17, 1, 0)
        end
      end

      context "when the time of day is picked too" do
        it "stores the given time" do
          content = build(:content, published_at: Time.zone.local(2012, 5, 20, 9, 15))

          assign_parts(content, :published_at, 2010, 3, 7, 14, 30)

          expect(content.published_at).to eq Time.zone.local(2010, 3, 7, 14, 30)
        end
      end
    end
  end
end
