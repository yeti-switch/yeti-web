# frozen_string_literal: true

RSpec.describe 'Create new CDR export', js: true do
  subject do
    click_submit 'Create Cdr export'
  end

  include_context :login_as_admin

  let!(:account) do
    create(:account, name: 'rspec')
  end

  context 'with all filled attributes' do
    before do
      visit new_cdr_export_path

      fill_in_chosen 'Fields', with: 'success', multiple: true
      fill_in_chosen 'Fields', with: 'id', multiple: true, exact: true
      fill_in_chosen 'Customer acc id eq', with: "#{account.name} | #{account.id}"
      fill_in 'Time start gteq', with: '2018-01-01'
      fill_in 'Time start lteq', with: '2018-03-01'
    end

    it 'cdr export should be created' do
      subject
      expect(page).to have_flash_message('Cdr export was successfully created.', type: :notice)

      cdr_export = CdrExport.last!
      expect(page).to have_current_path cdr_export_path(cdr_export)

      expect(cdr_export).to have_attributes(
        callback_url: nil,
        fields: %w[id success],
        status: 'Pending',
        filters: CdrExport::FiltersModel.new(
          'time_start_gteq' => '2018-01-01',
          'time_start_lteq' => '2018-03-01',
          'customer_acc_id_eq' => account.id.to_s
        )
      )
    end
  end

  context 'with inherited fields' do
    before do
      create :cdr_export, :completed, fields: %w[id success customer_id]
      visit new_cdr_export_path

      fill_in_chosen 'Customer acc id eq', with: "#{account.name} | #{account.id}"
      fill_in 'Time start gteq', with: '2018-01-01'
      fill_in 'Time start lteq', with: '2018-03-01'
    end

    it 'cdr export should be created' do
      subject
      expect(page).to have_text('Cdr export was successfully created.')

      cdr_export = CdrExport.last!
      expect(page).to have_current_path cdr_export_path(cdr_export)

      expect(cdr_export).to have_attributes(
        callback_url: nil,
        fields: %w[id customer_id success],
        status: 'Pending',
        filters: CdrExport::FiltersModel.new(
          'time_start_gteq' => '2018-01-01',
          'time_start_lteq' => '2018-03-01',
          'customer_acc_id_eq' => account.id.to_s
        )
      )
    end
  end
end
