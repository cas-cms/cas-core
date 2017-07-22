require 'rails_helper'

module Cas
  RSpec.describe SectionConfig do
    let(:slug) { 'news' }
    let(:section) { build(:section, slug: slug) }

    subject { described_class.new(section) }

    describe '#list_fields' do
      context 'when it is defined' do
        it 'returns what is in the file' do
          expect(subject.list_fields).to eq ['title', 'category']
        end
      end

      context 'when it is not defined' do
        let(:slug) { 'biography' }

        it 'returns standard fields' do
          expect(subject.list_fields).to eq ['title', 'created_at']
        end
      end
    end

    describe '#form_has_field?' do
      context 'when a section has not a field ' do
        it 'returns false' do
          form_has_field = subject.form_has_field?(:blab)
          expect(form_has_field).to eq false
        end
      end

      context 'when a section has a field ' do
        it 'returns true' do
          form_has_field = subject.form_has_field?(:title)
          expect(form_has_field).to eq true
        end
      end
    end

    describe '#list_order_by' do
      context 'when a section has field date' do
        it 'return the date in event' do
          expect(subject.list_order_by).to eq ['15-07-2019']
        end
      end
    end

  end
end
