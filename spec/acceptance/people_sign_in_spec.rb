require "rails_helper"

RSpec.feature 'Person' do
  let(:admin) { create(:person, :admin, sites: [site1, site2]) }
  let!(:site1) { create(:site, name: 'site1', domains: ['site1.com', 'site11.com']) }
  let!(:site2) { create(:site, name: 'site2', domains: ['site2.com']) }
  let!(:site3) { create(:site, name: 'site3', domains: ['site3.com']) }

  context 'As admin with access to site1.com, site11.com and site2.com' do
    background do
      Capybara.app_host = current_domain
      login(admin)
    end

    context 'when in site1.com' do
      let(:current_domain) { 'http://site1.com' }

      scenario 'I sign in successfully' do
        expect(all(:css, "body.site-#{site1.id}")).to be_present
      end
    end

    context 'when in site11.com' do
      let(:current_domain) { 'http://site11.com' }

      scenario 'I sign in successfully' do
        expect(all(:css, "body.site-#{site1.id}")).to be_present
      end
    end

    context 'when in site2.com' do
      let(:current_domain) { 'http://site2.com' }

      scenario 'I sign in successfully' do
        expect(all(:css, "body.site-#{site2.id}")).to be_present
      end
    end

    context 'when in site3.com' do
      let(:current_domain) { 'http://site3.com' }

      scenario 'I cannot sign in' do
        expect(all(:css, "body.site-#{site3.id}")).to_not be_present
      end
    end
  end
end
