require 'rails_helper'

module Cas
  RSpec.describe SectionForm do
    describe '#has_field?' do
      context 'when a section has not a field ' do
        it 'returns false' do

          # setup
          subject = ::Cas::SectionForm.new(
            "mysite",
            "news"
          )
          
          # execução
          has_field = subject.has_field?(:blab)

          #verificação
          expect(has_field).to eq false
        end
      end

      context 'when a section has a field ' do
        it 'returns true' do
          subject = ::Cas::SectionForm.new(
            "mysite",
            "news"
          )
          
          # execução
          has_field = subject.has_field?(:title)
          
          #verificação
          expect(has_field).to eq true
        end
      end

    end
  end
end
