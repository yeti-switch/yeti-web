# frozen_string_literal: true

RSpec.describe 'Show Log Api Logs' do
  include_context :login_as_admin

  let(:record_attrs) { {} }
  let!(:record) { FactoryBot.create(:api_log, record_attrs) }

  context 'when visit valid API Log' do
    let(:record_attrs) { super().merge tags: %w[tag1 tag2] }

    before { visit api_log_path(record) }

    it 'should render show page properly' do
      expect(page).to have_page_title record.id
      expect(page).to have_attribute_row('Controller', exact_text: record.controller)
      expect(page).to have_attribute_row('Tags', exact_text: 'tag1, tag2')
    end
  end
end
