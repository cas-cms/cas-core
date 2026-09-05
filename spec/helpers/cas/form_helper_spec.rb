require 'rails_helper'

module Cas
  RSpec.describe FormHelper, type: :helper do
    before do
      assign(:section, build(:section, slug: 'news'))
    end

    describe '#date_input_options' do
      context 'when the field format has no hour' do
        it 'builds a date input in the configured order' do
          expect(helper.date_input_options(:date)).to eq(
            as: :date,
            order: [:day, :month, :year]
          )
        end
      end

      context 'when the field format has an hour and a start year' do
        it 'builds a datetime input from that year up to the current year' do
          expect(helper.date_input_options(:published_at)).to eq(
            as: :datetime,
            order: [:day, :month, :year, :hour, :minute],
            start_year: 2007,
            end_year: Date.current.year
          )
        end

        it 'starts earlier when the stored value predates the start year' do
          stored = Time.zone.local(1999, 6, 1)

          expect(helper.date_input_options(:published_at, stored)).to include(
            start_year: 1999,
            end_year: Date.current.year
          )
        end

        it 'ends later when the stored value is in a future year' do
          stored = Time.zone.local(Date.current.year + 3, 1, 1)

          expect(helper.date_input_options(:published_at, stored)).to include(
            start_year: 2007,
            end_year: Date.current.year + 3
          )
        end
      end
    end
  end
end
