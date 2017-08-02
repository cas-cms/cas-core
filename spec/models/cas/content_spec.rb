require 'rails_helper'

module Cas
  RSpec.describe Content, type: :model do
    describe "callbacks" do

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
  end
end
