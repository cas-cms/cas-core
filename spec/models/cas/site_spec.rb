require 'rails_helper'

module Cas
  RSpec.describe Site, type: :model do
    describe 'slug' do
      context 'when empty' do
        it 'creates automatically' do
          site = ::Cas::Site.create!(name: 'my-site')
          expect(site.slug).to eq 'my-site'
        end
      end

      context 'when present' do
        it 'does not create a new one' do
          site = ::Cas::Site.create!(name: 'my-site', slug: 'custom')
          expect(site.slug).to eq 'custom'
        end
      end
    end
  end
end
