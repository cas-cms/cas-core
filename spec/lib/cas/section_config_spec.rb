require 'rails_helper'

module Cas
  RSpec.describe SectionConfig do
    let(:slug) { 'news' }
    let(:site) { build(:site, :yml_name) }
    let(:section) { build(:section, site: site, slug: slug) }

    subject { described_class.new(section) }

    describe '#accessible_by_person?' do
      context 'when accessible by admin only' do
        let(:section) { build(:section, :agenda, site: site) }

        context 'when person is a admin' do
          let(:person) { build(:person, :admin) }

          it 'returns true' do
            expect(subject).to be_accessible_by_person(person)
          end
        end

        context 'when person is a writer' do
          let(:person) { build(:person, :writer) }

          it 'returns false' do
            expect(subject).to_not be_accessible_by_person(person)
          end
        end
      end

      context 'when accessible by anyone' do
        let(:section) { build(:section, :news, site: site) }

        context 'when person is a admin' do
          let(:person) { build(:person, :admin) }

          it 'returns true' do
            expect(subject).to be_accessible_by_person(person)
          end
        end

        context 'when person is a writer' do
          let(:person) { build(:person, :writer) }

          it 'returns true' do
            expect(subject).to be_accessible_by_person(person)
          end
        end
      end
    end

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
      context 'when a section does not have the field' do
        let(:field) { :blab }

        it 'returns false' do
          form_has_field = subject.form_has_field?(field)
          expect(form_has_field).to eq false
        end
      end

      context 'when a section has a field ' do
        let(:field) { :title }

        it 'returns true' do
          form_has_field = subject.form_has_field?(field)
          expect(form_has_field).to eq true
        end
      end

      context 'when field has configurations' do
        let(:slug) { 'agenda' }
        let(:field) { :date }

        it 'returns true regardless' do
          form_has_field = subject.form_has_field?(field)
          expect(form_has_field).to eq true
        end
      end
    end

    describe '#list_order_by' do
      context 'when a section has order config' do
        let(:slug) { 'agenda' }

        it 'returns the configured field' do
          expect(subject.list_order_by).to eq ['order_field']
        end
      end

      context 'when a section does not have order config' do
        let(:slug) { 'news' }

        it 'returns created_at' do
          expect(subject.list_order_by).to eq ['created_at']
        end
      end
    end
  end
end
