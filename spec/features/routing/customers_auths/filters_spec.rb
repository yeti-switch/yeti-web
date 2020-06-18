# frozen_string_literal: true

RSpec.describe 'Filter Customers Auths records', :js do
  include_context :login_as_admin
  let!(:_customers_auths_list) { create_list :customers_auth, 2 }
  before { visit customers_auths_path }

  context 'by' do
    context '"SRC PREFIX"' do
      prefix = '_src_'
      let!(:customers_auth_src) { create(:customers_auth, src_prefix: [prefix]) }
      it 'should have filtered record only' do
        fill_in 'SRC Prefix', with: prefix
        click_button :Filter
        expect(page).to have_css 'table.index_table tbody tr', count: 1
        expect(page).to have_css '.resource_id_link', text: customers_auth_src.id
        expect(page).to have_field 'SRC Prefix', with: prefix
      end
    end

    context '"DST PREFIX"' do
      prefix = '_dst_'
      let!(:customers_auth_dst) { create(:customers_auth, dst_prefix: [prefix]) }
      it 'should have filtered record only' do
        fill_in 'DST Prefix', with: prefix
        click_button :Filter
        expect(page).to have_css 'table.index_table tbody tr', count: 1
        expect(page).to have_css '.resource_id_link', text: customers_auth_dst.id
        expect(page).to have_field 'DST Prefix', with: prefix
      end
    end

    context '"URI DOMAIN"' do
      domain = 'main.com'
      let!(:customers_auth_domain) { create(:customers_auth, uri_domain: [domain]) }
      it 'should have filtered record only' do
        fill_in 'URI Domain', with: domain
        click_button :Filter
        expect(page).to have_css 'table.index_table tbody tr', count: 1
        expect(page).to have_css '.resource_id_link', text: customers_auth_domain.id
        expect(page).to have_field 'URI Domain', with: domain
      end
    end

    context '"FROM DOMAIN"' do
      domain = 'main.com'
      let!(:customers_auth_f_domain) { create(:customers_auth, from_domain: [domain]) }
      it 'should have filtered record only' do
        fill_in 'From Domain', with: domain
        click_button :Filter
        expect(page).to have_css 'table.index_table tbody tr', count: 1
        expect(page).to have_css '.resource_id_link', text: customers_auth_f_domain.id
        expect(page).to have_field 'From Domain', with: domain
      end
    end

    context '"TO DOMAIN"' do
      domain = 'main.com'
      let!(:customers_auth_t_domain) { create(:customers_auth, to_domain: [domain]) }
      it 'should have filtered record only' do
        fill_in 'To Domain', with: domain
        click_button :Filter
        expect(page).to have_css 'table.index_table tbody tr', count: 1
        expect(page).to have_css '.resource_id_link', text: customers_auth_t_domain.id
        expect(page).to have_field 'To Domain', with: domain
      end
    end

    context '"X-YETI-AUTH"' do
      domain = 'string'
      let!(:customers_auth_x_domain) { create(:customers_auth, x_yeti_auth: [domain]) }
      it 'should have filtered record only' do
        fill_in 'X-Yeti-Auth', with: domain
        click_button :Filter
        expect(page).to have_css 'table.index_table tbody tr', count: 1
        expect(page).to have_css '.resource_id_link', text: customers_auth_x_domain.id
        expect(page).to have_field 'X-Yeti-Auth', with: domain
      end
    end
  end
end
