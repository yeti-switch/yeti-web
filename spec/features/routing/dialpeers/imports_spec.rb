# frozen_string_literal: true

RSpec.describe 'Dialpeer Imports' do
  subject do
    visit dialpeer_imports_path
  end

  include_context :login_as_admin
  let!(:routing_group) { FactoryBot.create(:routing_group) }
  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:gateway) { FactoryBot.create(:gateway, contractor: contractor) }
  let!(:dialpeer) { FactoryBot.create(:dialpeer, dialpeer_attrs) }
  let!(:dialpeer_attrs) do
    {
      prefix: '123456',
      src_rewrite_rule: '4587',
      dst_rewrite_rule: '789',
      gateway: gateway,
      routing_group: routing_group,
      src_rewrite_result: '1145',
      dst_rewrite_result: '86554',
      vendor: contractor
    }
  end
  let!(:import) { FactoryBot.create(:importing_dialpeer, :with_names, import_attrs) }
  let!(:import_attrs) do
    attrs = Importing::Dialpeer.import_attributes.map do |attr_name|
      [attr_name.to_sym, dialpeer.public_send(attr_name)]
    end
    {
      o_id: dialpeer.id,
      **attrs.to_h,
      is_changed: false
    }
  end

  it 'renders correct table row' do
    subject
    expect(page).to have_table_row(count: 1)
    expect(page).to have_table_cell column: 'Id', exact_text: import.id
    expect(page).to have_table_cell column: 'O id', exact_text: dialpeer.id
    expect(page).to have_table_cell column: 'Is changed', exact_text: 'No'
    expect(page).to have_table_cell column: 'Prefix', exact_text: import.prefix
    expect(page).to have_table_cell column: 'Enabled', exact_text: import.enabled
    expect(page).to have_table_cell column: 'Priority', exact_text: import.priority
    expect(page).to have_table_cell column: 'Force hit rate', exact_text: import.force_hit_rate
    expect(page).to have_table_cell column: 'Initial interval', exact_text: import.initial_interval
    expect(page).to have_table_cell column: 'Initial rate', exact_text: import.initial_rate
    expect(page).to have_table_cell column: 'Next interval', exact_text: import.next_interval
    expect(page).to have_table_cell column: 'Next rate', exact_text: import.next_rate
    expect(page).to have_table_cell column: 'Connect fee', exact_text: import.connect_fee
    expect(page).to have_table_cell column: 'Reverse billing', exact_text: import.reverse_billing
    expect(page).to have_table_cell column: 'Lcr rate multiplier', exact_text: import.lcr_rate_multiplier
    expect(page).to have_table_cell column: 'Gateway', exact_text: import.gateway.name
    expect(page).to have_table_cell column: 'Gateway group', exact_text: 'Empty'
    expect(page).to have_table_cell column: 'Routing group', exact_text: import.routing_group.name
    expect(page).to have_table_cell column: 'Routing tag ids', exact_text: import.routing_tag_ids
    expect(page).to have_table_cell column: 'Routing tag mode', exact_text: import.routing_tag_mode_name
    expect(page).to have_table_cell column: 'Vendor', exact_text: import.vendor.name
    expect(page).to have_table_cell column: 'Account', exact_text: import.account.name
    expect(page).to have_table_cell column: 'Routeset discriminator', exact_text: import.routeset_discriminator.name
    expect(page).to have_table_cell column: 'Valid from', exact_text: import.valid_from
    expect(page).to have_table_cell column: 'Valid till', exact_text: import.valid_till
    expect(page).to have_table_cell column: 'Acd limit', exact_text: import.acd_limit
    expect(page).to have_table_cell column: 'Asr limit', exact_text: import.asr_limit
    expect(page).to have_table_cell column: 'Short calls limit', exact_text: import.short_calls_limit
    expect(page).to have_table_cell column: 'Capacity', exact_text: import.capacity
    expect(page).to have_table_cell column: 'Src rewrite rule', exact_text: import.src_rewrite_rule
    expect(page).to have_table_cell column: 'Src rewrite result', exact_text: import.src_rewrite_result
    expect(page).to have_table_cell column: 'Dst rewrite rule', exact_text: import.dst_rewrite_rule
    expect(page).to have_table_cell column: 'Dst rewrite result', exact_text: import.dst_rewrite_result
  end

  context 'with gateway_group' do
    let!(:gateway_group) { FactoryBot.create(:gateway_group, vendor: contractor) }
    let(:dialpeer_attrs) do
      super().merge gateway: nil,
                    gateway_group: gateway_group
    end

    it 'renders correct table row' do
      subject
      expect(page).to have_table_row(count: 1)
      expect(page).to have_table_cell column: 'Id', exact_text: import.id
      expect(page).to have_table_cell column: 'O id', exact_text: dialpeer.id
      expect(page).to have_table_cell column: 'Is changed', exact_text: 'No'
      expect(page).to have_table_cell column: 'Prefix', exact_text: import.prefix
      expect(page).to have_table_cell column: 'Enabled', exact_text: import.enabled
      expect(page).to have_table_cell column: 'Priority', exact_text: import.priority
      expect(page).to have_table_cell column: 'Force hit rate', exact_text: import.force_hit_rate
      expect(page).to have_table_cell column: 'Initial interval', exact_text: import.initial_interval
      expect(page).to have_table_cell column: 'Initial rate', exact_text: import.initial_rate
      expect(page).to have_table_cell column: 'Next interval', exact_text: import.next_interval
      expect(page).to have_table_cell column: 'Next rate', exact_text: import.next_rate
      expect(page).to have_table_cell column: 'Connect fee', exact_text: import.connect_fee
      expect(page).to have_table_cell column: 'Reverse billing', exact_text: import.reverse_billing
      expect(page).to have_table_cell column: 'Lcr rate multiplier', exact_text: import.lcr_rate_multiplier
      expect(page).to have_table_cell column: 'Gateway', exact_text: 'Empty'
      expect(page).to have_table_cell column: 'Gateway group', exact_text: import.gateway_group.name
      expect(page).to have_table_cell column: 'Routing group', exact_text: import.routing_group.name
      expect(page).to have_table_cell column: 'Routing tag ids', exact_text: import.routing_tag_ids
      expect(page).to have_table_cell column: 'Routing tag mode', exact_text: import.routing_tag_mode_name
      expect(page).to have_table_cell column: 'Vendor', exact_text: import.vendor.name
      expect(page).to have_table_cell column: 'Account', exact_text: import.account.name
      expect(page).to have_table_cell column: 'Routeset discriminator', exact_text: import.routeset_discriminator.name
      expect(page).to have_table_cell column: 'Valid from', exact_text: import.valid_from
      expect(page).to have_table_cell column: 'Valid till', exact_text: import.valid_till
      expect(page).to have_table_cell column: 'Acd limit', exact_text: import.acd_limit
      expect(page).to have_table_cell column: 'Asr limit', exact_text: import.asr_limit
      expect(page).to have_table_cell column: 'Short calls limit', exact_text: import.short_calls_limit
      expect(page).to have_table_cell column: 'Capacity', exact_text: import.capacity
      expect(page).to have_table_cell column: 'Src rewrite rule', exact_text: import.src_rewrite_rule
      expect(page).to have_table_cell column: 'Src rewrite result', exact_text: import.src_rewrite_result
      expect(page).to have_table_cell column: 'Dst rewrite rule', exact_text: import.dst_rewrite_rule
      expect(page).to have_table_cell column: 'Dst rewrite result', exact_text: import.dst_rewrite_result
    end
  end

  context 'Apply unique columns', js: true do
    subject do
      visit dialpeer_imports_path
      click_on 'Apply unique columns'
      fill_form!
      click_on 'OK'
    end

    let(:unique_columns) { %w[prefix] }
    let(:fill_form!) { fill_in_tom_select 'Unique Columns', with: unique_columns, search: true }
    let(:import_attrs) { super().merge(o_id: nil, is_changed: nil) }

    shared_examples :should_successfully_apply do
      let(:expected_import_attributes) { { o_id: nil, is_changed: true } }

      it 'should successfully apply' do
        subject
        expect(page).to have_flash_message('Unique columns applied!', type: :notice)
        expect(import.reload).to have_attributes(expected_import_attributes)
      end
    end

    context 'when form submitted without unique columns and additional filter' do
      let(:fill_form!) { nil }

      include_examples :should_successfully_apply
    end

    context 'when form submitted without unique columns but with additional filter' do
      let(:fill_form!) { fill_in 'Additional SQL filter', with: "tb.id=#{dialpeer.id}" }

      include_examples :should_successfully_apply
    end

    context 'when unique columns match single record' do
      include_examples :should_successfully_apply do
        let(:expected_import_attributes) do
          {
            o_id: dialpeer.id,
            is_changed: false
          }
        end
      end
    end

    context 'when unique columns match multiple records' do
      let!(:second_dialpeer) { FactoryBot.create(:dialpeer, dialpeer_attrs) }

      include_examples :should_successfully_apply do
        let(:expected_import_attributes) do
          {
            o_id: be(dialpeer.id).or(be(second_dialpeer.id)),
            is_changed: false
          }
        end
      end
    end

    context 'when unique columns do not match any record' do
      let(:import_attrs) { super().merge(prefix: '999999') }

      include_examples :should_successfully_apply
    end

    context 'when import has changed attributes' do
      let(:import_attrs) { super().merge(initial_rate: 0.99) }

      include_examples :should_successfully_apply do
        let(:expected_import_attributes) do
          {
            o_id: dialpeer.id,
            is_changed: true
          }
        end
      end
    end
  end
end
