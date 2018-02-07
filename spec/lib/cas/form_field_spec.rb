require 'rails_helper'

module Cas
  RSpec.describe FormField do
    let(:slug) { 'agenda' }
    let(:field) { 'title' }
    let(:site) { build(:site, :yml_name) }
    let(:section) { build(:section, site: site, slug: slug) }

    subject { described_class.new(section, field) }

    describe '#language' do
      context 'when there is no value' do
        let(:field) { :location }

        it 'returns nil' do
          expect(subject.language).to eq nil
        end
      end

      context 'when there is a value' do
        let(:field) { :date }

        it 'returns the value from the file' do
          expect(subject.language).to eq "pt-br"
        end
      end
    end

    describe '#format' do
      context 'when there is no format' do
        it 'returns the format' do
          expect(subject.format).to eq [:day, :month, :year]
        end
      end

      context 'when there is a format' do
        let(:field) { :date }

        it 'returns the format' do
          expect(subject.format).to eq [:day, :month, :year]
        end
      end
    end
  end
end
