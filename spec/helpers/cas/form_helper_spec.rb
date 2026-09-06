require 'rails_helper'

module Cas
  RSpec.describe FormHelper, type: :helper do
    let(:slug) { 'news' }

    before do
      assign(:section, build(:section, slug: slug))
    end

    describe '#date_input_options' do
      context 'when the field has no format and no start year' do
        it 'builds a date input in day, month, year order' do
          expect(helper.date_input_options(:date)).to eq(
            as: :date,
            order: [:day, :month, :year]
          )
        end
      end

      context 'when the field has a start year' do
        it 'spans the start year to the current year' do
          expect(helper.date_input_options(:published_at)).to eq(
            as: :date,
            order: [:day, :month, :year],
            start_year: 1900,
            end_year: Date.current.year
          )
        end

        it 'starts earlier when the stored value predates the start year' do
          stored = Time.zone.local(1850, 6, 1)

          expect(helper.date_input_options(:published_at, stored)).to include(
            start_year: 1850,
            end_year: Date.current.year
          )
        end

        it 'ends later when the stored value is in a future year' do
          stored = Time.zone.local(Date.current.year + 3, 1, 1)

          expect(helper.date_input_options(:published_at, stored)).to include(
            start_year: 1900,
            end_year: Date.current.year + 3
          )
        end
      end

      context 'when the field format includes the hour' do
        let(:slug) { 'agenda' }

        it 'builds a datetime input' do
          expect(helper.date_input_options(:date)).to eq(
            as: :datetime,
            order: [:day, :month, :year, :hour, :minute],
            start_year: 2017,
            end_year: Date.current.year
          )
        end
      end
    end
  end
end
