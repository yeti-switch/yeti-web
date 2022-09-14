# frozen_string_literal: true

RSpec.describe 'Create new Dialpeer', js: true do
  subject do
    visit new_dialpeer_path
    fill_form!
    submit_form!
  end

  let(:submit_form!) do
    click_button 'Create Dialpeer'
  end

  include_context :login_as_admin

  let!(:vendor) { FactoryBot.create(:vendor, name: 'John Doe') }
  let!(:account) { FactoryBot.create(:account, contractor: vendor) }
  let!(:routing_group) { FactoryBot.create(:routing_group) }
  let!(:routeset_discriminator) { FactoryBot.create(:routeset_discriminator) }
  let!(:gateway) { FactoryBot.create(:gateway, contractor: vendor) }
  let!(:routing_tags) do
    FactoryBot.create_list(:routing_tag, 5)
  end
  before do
    FactoryBot.create(:routing_group)
    FactoryBot.create(:routeset_discriminator)
    vendor_2 = FactoryBot.create(:vendor)
    FactoryBot.create(:account, contractor: vendor_2)
    FactoryBot.create(:gateway, contractor: vendor_2)
    FactoryBot.create(:account, contractor: vendor)
    FactoryBot.create(:gateway, contractor: vendor)
  end
  let(:fill_form!) do
    fill_in 'Initial rate', with: '0.1'
    fill_in 'Next rate', with: '0.2'
    fill_in_chosen 'Vendor', with: vendor.display_name, ajax: true
    fill_in_chosen 'Account', with: account.display_name, ajax: true
    fill_in_chosen 'Routing group', with: routing_group.display_name
    fill_in_chosen 'Routeset discriminator', with: routeset_discriminator.display_name
    fill_in_chosen 'Gateway', with: gateway.display_name
  end

  it 'creates record' do
    expect {
      subject
      expect(page).to have_flash_message('Dialpeer was successfully created.', type: :notice)
    }.to change { Dialpeer.count }.by(1)

    record = Dialpeer.last
    expect(record).to have_attributes(
      vendor_id: vendor.id,
      account_id: account.id,
      routing_group_id: routing_group.id,
      routeset_discriminator_id: routeset_discriminator.id,
      initial_rate: 0.1,
      next_rate: 0.2,
      routing_tag_ids: []
    )
  end

  context 'with filled routing tags' do
    let(:fill_form!) do
      super()
      fill_in_chosen 'Routing tags', with: routing_tags[4].name, multiple: true
      fill_in_chosen 'Routing tags', with: routing_tags[2].name, multiple: true
      fill_in_chosen 'Routing tags', with: Routing::RoutingTag::ANY_TAG, multiple: true
      fill_in_chosen 'Routing tags', with: routing_tags[0].name, multiple: true
    end

    it 'creates record' do
      expect {
        subject
        expect(page).to have_flash_message('Dialpeer was successfully created.', type: :notice)
      }.to change { Dialpeer.count }.by(1)

      record = Dialpeer.last
      expect(record).to have_attributes(
                          vendor_id: vendor.id,
                          account_id: account.id,
                          routing_group_id: routing_group.id,
                          routeset_discriminator_id: routeset_discriminator.id,
                          initial_rate: 0.1,
                          next_rate: 0.2,
                          # routing_tag_ids are correctly sorted
                          routing_tag_ids: [
                            routing_tags[0].id,
                            routing_tags[2].id,
                            routing_tags[4].id,
                            nil
                          ]
                        )
    end
  end

  context 'with only default fields filled' do
    let(:fill_form!) { nil }

    it 'does not create record' do
      expect {
        subject
        expect(page).to have_semantic_error_texts(
                          "Routing group must exist and can't be blank",
                          "Account must exist and can't be blank",
                          "Vendor must exist, can't be blank, and Is not vendor",
                          "Initial rate can't be blank and is not a number",
                          "Next rate can't be blank and is not a number",
                          'Specify a gateway_group or a gateway'
                        )
      }.to change { Dialpeer.count }.by(0)
    end
  end

  context 'with all fields cleared' do
    let(:fill_form!) do
      fill_in 'Dst number min length', with: ''
      fill_in 'Dst number max length', with: ''
      select_by_value('', from: 'Routing tag mode')
      fill_in 'Priority', with: ''
      fill_in 'Initial interval', with: ''
      fill_in 'Next interval', with: ''
      fill_in 'Lcr rate multiplier', with: ''
      fill_in 'Connect fee', with: ''
      fill_in 'Valid from', with: ''
      fill_in 'Valid till', with: ''
      fill_in 'Acd limit', with: ''
      fill_in 'Asr limit', with: ''
      fill_in 'Short calls limit', with: ''
    end

    it 'does not create record' do
      expect {
        subject
        expect(page).to have_semantic_error_texts(
                          "Routing group must exist and can't be blank",
                          "Account must exist and can't be blank",
                          "Vendor must exist, can't be blank, and Is not vendor",
                          "Routing tag mode must exist and can't be blank",
                          "Valid from can't be blank",
                          "Valid till can't be blank",
                          "Initial rate can't be blank and is not a number",
                          "Next rate can't be blank and is not a number",
                          "Initial interval can't be blank and is not a number",
                          "Next interval can't be blank and is not a number",
                          "Connect fee can't be blank and is not a number",
                          "Lcr rate multiplier can't be blank and is not a number",
                          'Acd limit is not a number',
                          'Asr limit is not a number',
                          'Short calls limit is not a number',
                          "Dst number min length can't be blank and is not a number",
                          "Dst number max length can't be blank and is not a number",
                          "Priority can't be blank",
                          'Specify a gateway_group or a gateway'
                        )
      }.to change { Dialpeer.count }.by(0)
    end
  end
end
