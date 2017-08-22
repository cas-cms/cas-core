require 'spec_helper'
require 'cas/config'

module Cas
  RSpec.describe Config do
    let(:custom_fixture) { nil }

    subject { described_class.new(filename: custom_fixture) }

    describe '#updates' do
      context 'when file has contents' do
        it 'returns what is in the file' do
          expect(subject.uploads).to eq({
            cache_directory_prefix: 'cache',
            store_directory_prefix: 'uploads'
          })
        end
      end

      context 'when file has no content' do
        let(:custom_fixture) { 'spec/fixtures/empty_cas.yml' }

        it 'returns empty' do
          expect(subject.uploads).to eq({
            cache_directory_prefix: "cache",
            store_directory_prefix: "store"
          })
        end
      end
    end
  end
end
