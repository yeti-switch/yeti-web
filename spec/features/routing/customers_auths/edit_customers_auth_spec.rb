# frozen_string_literal: true

RSpec.describe 'Edit Customers Auth', type: :feature do
  include_context :login_as_admin

  subject do
    visit edit_customers_auth_path(record.id)
    fill_form!
    submit_form!
  end

  let(:fill_form!) { nil }
  let(:submit_form!) { nil }

  let!(:record) { FactoryBot.create(:customers_auth, **record_attrs) }
  let(:record_attrs) { { customer: contractor, account:, gateway:, src_numberlist:, dst_numberlist: } }
  let(:contractor) { FactoryBot.create(:customer) }
  let(:account) { FactoryBot.create(:account, contractor:) }
  let(:gateway) { FactoryBot.create(:gateway, contractor:) }
  let(:src_numberlist) { FactoryBot.create(:numberlist) }
  let(:dst_numberlist) { FactoryBot.create(:numberlist) }

  it 'should load edit page', js: true do
    subject

    expect(page).to have_field_chosen('SRC Numberlist', with: src_numberlist.display_name)
    expect(page).to have_field_chosen('DST Numberlist', with: dst_numberlist.display_name)
  end

  context 'unset "Tag action value"' do
    include_examples :test_unset_tag_action_value,
                     controller_name: :customers_auths,
                     factory: :customers_auth do
      let(:record_attrs) { super().merge(tag_action_value: [tag.id]) }

      include_examples :increments_customers_auth_state
    end
  end
end
