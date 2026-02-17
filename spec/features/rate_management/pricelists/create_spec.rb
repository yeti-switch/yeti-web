# frozen_string_literal: true

RSpec.describe 'Rate Management Pricelist Create', js: true do
  include_context :login_as_admin

  subject do
    visit new_rate_management_pricelist_path
    fill_form!
    click_on 'Create Pricelist'
  end

  let(:name) { 'new_pricelist' }
  let(:fill_form!) do
    fill_in 'Name', with: name
    fill_in_tom_select 'Project', with: project.name
    attach_file 'File', csv_file.path
  end
  let!(:project) { FactoryBot.create(:rate_management_project, :filled, :with_routing_tags) }

  let(:csv_headers) do
    [
      'Prefix', 'Initial Rate', 'Next Rate', 'Connect Fee', 'Dst Number Min Length', 'Dst Number Max Length',
      'Initial Interval', 'Next Interval', 'Routing Tag Names', 'Routing Tag Mode'
    ]
  end
  let(:csv_attrs_list) do
    [
      {
        prefix: '521',
        initial_rate: '1',
        next_rate: '2',
        connect_fee: '0.5',
        dst_number_min_length: '25',
        dst_number_max_length: '60',
        initial_interval: '1',
        next_interval: '2',
        routing_tag_names: nil,
        routing_tag_mode: 'OR'
      }
    ]
  end
  let(:csv_file) do
    rows = csv_attrs_list.map do |attrs|
      csv_headers.map { |header| attrs.fetch(header.parameterize.underscore.to_sym) }
    end
    create_csv_file(csv_headers, rows)
  end

  it 'should be create pricelist' do
    expect(RateManagement::PricelistItemsParser).to receive(:call).and_call_original
    expect(RateManagement::VerifyPricelistItems).to receive(:call).and_call_original
    expect(RateManagement::CreatePricelistItems).to receive(:call).and_call_original
    expect do
      subject
      expect(page).to have_flash_message('Pricelist was successfully created.', type: :notice)
    end.to change { RateManagement::Pricelist.count }.by(1).and change { RateManagement::PricelistItem.count }.by(1)

    pricelist = RateManagement::Pricelist.last
    expect(page).to have_current_path rate_management_pricelist_pricelist_items_path(pricelist)
    expect(pricelist).to have_attributes(
                            name: name,
                            state_id: RateManagement::Pricelist::CONST::STATE_ID_NEW,
                            project_id: project.id,
                            valid_till: 5.years.from_now.beginning_of_day,
                            valid_from: nil,
                            filename: File.basename(csv_file.path),
                            retain_enabled: true,
                            retain_priority: true
                          )
  end

  context 'with "Retain enabled" No' do
    let(:fill_form!) do
      super()
      fill_in_tom_select 'Retain enabled', with: 'No'
    end

    it 'should be create pricelist' do
      expect(RateManagement::PricelistItemsParser).to receive(:call).and_call_original
      expect(RateManagement::VerifyPricelistItems).to receive(:call).and_call_original
      expect(RateManagement::CreatePricelistItems).to receive(:call).and_call_original
      expect do
        subject
        expect(page).to have_flash_message('Pricelist was successfully created.', type: :notice)
      end.to change { RateManagement::Pricelist.count }.by(1).and change { RateManagement::PricelistItem.count }.by(1)

      pricelist = RateManagement::Pricelist.last
      expect(page).to have_current_path rate_management_pricelist_pricelist_items_path(pricelist)
      expect(pricelist).to have_attributes(
                             name: name,
                             state_id: RateManagement::Pricelist::CONST::STATE_ID_NEW,
                             project_id: project.id,
                             valid_from: nil,
                             valid_till: 5.years.from_now.beginning_of_day,
                             filename: File.basename(csv_file.path),
                             retain_enabled: false,
                             retain_priority: true
                           )
    end
  end

  context 'with "Retain priority" No' do
    let(:fill_form!) do
      super()
      fill_in_tom_select 'Retain priority', with: 'No'
    end

    it 'should be create pricelist' do
      expect(RateManagement::PricelistItemsParser).to receive(:call).and_call_original
      expect(RateManagement::VerifyPricelistItems).to receive(:call).and_call_original
      expect(RateManagement::CreatePricelistItems).to receive(:call).and_call_original
      expect do
        subject
        expect(page).to have_flash_message('Pricelist was successfully created.', type: :notice)
      end.to change { RateManagement::Pricelist.count }.by(1).and change { RateManagement::PricelistItem.count }.by(1)

      pricelist = RateManagement::Pricelist.last
      expect(page).to have_current_path rate_management_pricelist_pricelist_items_path(pricelist)
      expect(pricelist).to have_attributes(
                             name: name,
                             state_id: RateManagement::Pricelist::CONST::STATE_ID_NEW,
                             project_id: project.id,
                             valid_till: 5.years.from_now.beginning_of_day,
                             filename: File.basename(csv_file.path),
                             retain_enabled: true,
                             retain_priority: false
                           )
    end
  end

  context 'when project has applied pricelist' do
    before do
      FactoryBot.create(:rate_management_pricelist, :applied, project: project, items_qty: 2)
    end

    it 'should be create pricelist' do
      expect(RateManagement::PricelistItemsParser).to receive(:call).and_call_original
      expect(RateManagement::CreatePricelistItems).to receive(:call).and_call_original
      expect do
        subject
        expect(page).to have_flash_message('Pricelist was successfully created.', type: :notice)
      end.to change { RateManagement::Pricelist.count }.by(1).and change { RateManagement::PricelistItem.count }.by(1)

      pricelist = RateManagement::Pricelist.last
      expect(page).to have_current_path rate_management_pricelist_pricelist_items_path(pricelist)
      expect(pricelist).to have_attributes(
                             name: name,
                             state_id: RateManagement::Pricelist::CONST::STATE_ID_NEW,
                             project_id: project.id,
                             valid_till: 5.years.from_now.beginning_of_day,
                             filename: File.basename(csv_file.path),
                             retain_enabled: true,
                             retain_priority: true
                           )
    end
  end

  context 'when another projects has all kinds of pricelists' do
    before do
      project_1 = FactoryBot.create(:rate_management_project, :filled)
      project_2 = FactoryBot.create(:rate_management_project, :filled)
      FactoryBot.create(:rate_management_pricelist, :new, project: project_1, items_qty: 2)
      FactoryBot.create(:rate_management_pricelist, :dialpeers_detected, project: project_2, items_qty: 2)
      FactoryBot.create(:rate_management_pricelist, :applied, project: project_1, items_qty: 2)
    end

    it 'should be create pricelist' do
      expect(RateManagement::PricelistItemsParser).to receive(:call).and_call_original
      expect(RateManagement::VerifyPricelistItems).to receive(:call).and_call_original
      expect(RateManagement::CreatePricelistItems).to receive(:call).and_call_original
      expect do
        subject
        expect(page).to have_flash_message('Pricelist was successfully created.', type: :notice)
      end.to change { RateManagement::Pricelist.count }.by(1).and change { RateManagement::PricelistItem.count }.by(1)

      pricelist = RateManagement::Pricelist.last
      expect(page).to have_current_path rate_management_pricelist_pricelist_items_path(pricelist)
      expect(pricelist).to have_attributes(
                             name: name,
                             state_id: RateManagement::Pricelist::CONST::STATE_ID_NEW,
                             project_id: project.id,
                             valid_till: 5.years.from_now.beginning_of_day,
                             filename: File.basename(csv_file.path),
                             retain_enabled: true,
                             retain_priority: true
                           )
    end
  end

  context 'with changed Valid till' do
    let(:fill_form!) do
      super()
      fill_in 'Valid till', with: valid_till
    end

    context 'when valid_till is 2 months from now' do
      let(:valid_till) { 2.months.from_now.round }

      it 'should be create pricelist' do
        expect(RateManagement::PricelistItemsParser).to receive(:call).and_call_original
        expect(RateManagement::VerifyPricelistItems).to receive(:call).and_call_original
        expect(RateManagement::CreatePricelistItems).to receive(:call).and_call_original
        expect do
          subject
          expect(page).to have_flash_message('Pricelist was successfully created.', type: :notice)
        end.to change { RateManagement::Pricelist.count }.by(1).and change { RateManagement::PricelistItem.count }.by(1)

        pricelist = RateManagement::Pricelist.last
        expect(page).to have_current_path rate_management_pricelist_pricelist_items_path(pricelist)
        expect(pricelist).to have_attributes(
                               name: name,
                               state_id: RateManagement::Pricelist::CONST::STATE_ID_NEW,
                               project_id: project.id,
                               valid_till: valid_till,
                               valid_from: nil,
                               filename: File.basename(csv_file.path),
                               retain_enabled: true,
                               retain_priority: true
                             )
      end
    end

    context 'when valid_till is 2 hours from now' do
      let(:valid_till) { 2.hours.from_now.round }

      it 'should be create pricelist' do
        expect(RateManagement::PricelistItemsParser).to receive(:call).and_call_original
        expect(RateManagement::VerifyPricelistItems).to receive(:call).and_call_original
        expect(RateManagement::CreatePricelistItems).to receive(:call).and_call_original
        expect do
          subject
          expect(page).to have_flash_message('Pricelist was successfully created.', type: :notice)
        end.to change { RateManagement::Pricelist.count }.by(1).and change { RateManagement::PricelistItem.count }.by(1)

        pricelist = RateManagement::Pricelist.last
        expect(page).to have_current_path rate_management_pricelist_pricelist_items_path(pricelist)
        expect(pricelist).to have_attributes(
                               name: name,
                               state_id: RateManagement::Pricelist::CONST::STATE_ID_NEW,
                               project_id: project.id,
                               valid_till: valid_till,
                               valid_from: nil,
                               filename: File.basename(csv_file.path),
                               retain_enabled: true,
                               retain_priority: true
                             )
      end
    end

    context 'when valid_till is now' do
      let(:valid_till) { Time.zone.now }

      it 'should be raise validation error' do
        expect do
          subject
          expect(page).to have_semantic_errors(count: 1)
        end.not_to change { RateManagement::Pricelist.count }

        expect(page).to have_semantic_error('Valid till must be in future')
      end
    end

    context 'when valid_till in the past' do
      let(:valid_till) { 1.day.ago.round }

      it 'should be raise validation error' do
        expect do
          subject
          expect(page).to have_semantic_errors(count: 1)
        end.not_to change { RateManagement::Pricelist.count }

        expect(page).to have_semantic_error('Valid till must be in future')
      end
    end
  end

  context 'with changed Valid from' do
    let(:fill_form!) do
      super()
      fill_in 'Valid from', with: valid_from
    end

    context 'when valid_from is 2 days from now' do
      let(:valid_from) { 2.days.from_now.round }

      it 'should be create pricelist' do
        expect(RateManagement::PricelistItemsParser).to receive(:call).and_call_original
        expect(RateManagement::VerifyPricelistItems).to receive(:call).and_call_original
        expect(RateManagement::CreatePricelistItems).to receive(:call).and_call_original
        expect do
          subject
          expect(page).to have_flash_message('Pricelist was successfully created.', type: :notice)
        end.to change { RateManagement::Pricelist.count }.by(1).and change { RateManagement::PricelistItem.count }.by(1)

        pricelist = RateManagement::Pricelist.last
        expect(page).to have_current_path rate_management_pricelist_pricelist_items_path(pricelist)
        expect(pricelist).to have_attributes(
                               name: name,
                               state_id: RateManagement::Pricelist::CONST::STATE_ID_NEW,
                               project_id: project.id,
                               valid_till: 5.years.from_now.beginning_of_day,
                               valid_from: valid_from,
                               filename: File.basename(csv_file.path)
                             )
      end
    end

    context 'when valid_from is 2 hours from now' do
      let(:valid_from) { 2.hours.from_now.round }

      it 'should be create pricelist' do
        expect(RateManagement::PricelistItemsParser).to receive(:call).and_call_original
        expect(RateManagement::VerifyPricelistItems).to receive(:call).and_call_original
        expect(RateManagement::CreatePricelistItems).to receive(:call).and_call_original
        expect do
          subject
          expect(page).to have_flash_message('Pricelist was successfully created.', type: :notice)
        end.to change { RateManagement::Pricelist.count }.by(1).and change { RateManagement::PricelistItem.count }.by(1)

        pricelist = RateManagement::Pricelist.last
        expect(page).to have_current_path rate_management_pricelist_pricelist_items_path(pricelist)
        expect(pricelist).to have_attributes(
                               name: name,
                               state_id: RateManagement::Pricelist::CONST::STATE_ID_NEW,
                               project_id: project.id,
                               valid_till: 5.years.from_now.beginning_of_day,
                               valid_from: valid_from,
                               filename: File.basename(csv_file.path)
                             )
      end
    end

    context 'when valid_from is now' do
      let(:valid_from) { Time.zone.now }

      it 'should be raise validation error' do
        expect do
          subject
          expect(page).to have_semantic_errors(count: 1)
        end.not_to change { RateManagement::Pricelist.count }

        expect(page).to have_semantic_error('Valid from must be in future')
      end
    end

    context 'when valid_from in the past' do
      let(:valid_from) { 1.day.ago.round }

      it 'should be raise validation error' do
        expect do
          subject
          expect(page).to have_semantic_errors(count: 1)
        end.not_to change { RateManagement::Pricelist.count }

        expect(page).to have_semantic_error('Valid from must be in future')
      end
    end

    context 'when valid_from = valid_till' do
      let(:fill_form!) do
        super()
        fill_in 'Valid till', with: valid_till
      end
      let(:valid_till) { valid_from }
      let(:valid_from) { 2.days.from_now.round }

      it 'should be raise validation error' do
        expect do
          subject
          expect(page).to have_semantic_errors(count: 1)
        end.not_to change { RateManagement::Pricelist.count }

        expect(page).to have_semantic_error('Valid from must be earlier than Valid till')
      end
    end

    context 'when valid_from > valid_till' do
      let(:fill_form!) do
        super()
        fill_in 'Valid till', with: valid_till
      end
      let(:valid_till) { 15.days.from_now }
      let(:valid_from) { 16.days.from_now }

      it 'should be raise validation error' do
        expect do
          subject
          expect(page).to have_semantic_errors(count: 1)
        end.not_to change { RateManagement::Pricelist.count }

        expect(page).to have_semantic_error('Valid from must be earlier than Valid till')
      end
    end
  end

  context 'with empty form' do
    let(:fill_form!) { nil }

    it 'should be raise validation error' do
      expect do
        subject
        expect(page).to have_semantic_errors(count: 3)
      end.not_to change { RateManagement::Pricelist.count }

      expect(page).to have_semantic_error("Name can't be blank")
      expect(page).to have_semantic_error("Project can't be blank")
      expect(page).to have_semantic_error("File can't be blank")

      expect(page).to have_text(
                        "Allowed headers: #{RateManagement::PricelistItemsParser.humanized_headers.join(', ')}"
                      )
    end

    context 'with clear Valid till' do
      let(:fill_form!) do
        fill_in 'Valid till', with: ''
      end

      it 'should be raise validation error' do
        expect do
          subject
          expect(page).to have_semantic_errors(count: 4)
        end.not_to change { RateManagement::Pricelist.count }

        expect(page).to have_semantic_error("Name can't be blank")
        expect(page).to have_semantic_error("Project can't be blank")
        expect(page).to have_semantic_error("Valid till can't be blank")
        expect(page).to have_semantic_error("File can't be blank")
      end
    end
  end

  context 'when project has new pricelist' do
    before do
      FactoryBot.create(:rate_management_pricelist, :new, project: project, items_qty: 2)
    end

    it 'shows validation errors' do
      expect do
        subject
        expect(page).to have_semantic_errors(count: 1)
      end.not_to change { RateManagement::Pricelist.count }

      expect(page).to have_semantic_error('Project have New or Dialpeers detection pricelist, please delete or complete it first')
    end
  end

  context 'when project has dialpeers_detected pricelist' do
    before do
      FactoryBot.create(:rate_management_pricelist, :dialpeers_detected, project: project, items_qty: 2)
    end

    it 'shows validation errors' do
      expect do
        subject
        expect(page).to have_semantic_errors(count: 1)
      end.not_to change { RateManagement::Pricelist.count }

      expect(page).to have_semantic_error('Project have New or Dialpeers detection pricelist, please delete or complete it first')
    end
  end

  context 'when raises RateManagement::PricelistItemsParser::Error' do
    before { allow(RateManagement::PricelistItemsParser).to receive(:call).once.and_raise(error) }

    let(:error) { RateManagement::PricelistItemsParser::Error.new('with some error') }

    it 'should be raise validation error' do
      expect do
        subject
        expect(page).to have_semantic_errors(count: 1)
      end.not_to change { RateManagement::Pricelist.count }

      expect(page).to have_semantic_error('File with some error')
    end
  end

  context 'when raises RateManagement::VerifyPricelistItems::Error' do
    before { allow(RateManagement::VerifyPricelistItems).to receive(:call).once.and_raise(error) }

    let(:error) { RateManagement::VerifyPricelistItems::Error.new(['error 1', 'error 2']) }

    it 'should be raise validation error' do
      expect do
        subject
        expect(page).to have_semantic_errors(count: 2)
      end.not_to change { RateManagement::Pricelist.count }

      expect(page).to have_semantic_error('File error 1')
      expect(page).to have_semantic_error('File error 2')
    end
  end

  context 'when raises RateManagement::CreatePricelistItems::Error' do
    before { allow(RateManagement::CreatePricelistItems).to receive(:call).once.and_raise(error) }

    let(:error) { RateManagement::CreatePricelistItems::Error.new('some error') }

    it 'should be raise validation error' do
      expect do
        subject
        expect(page).to have_semantic_errors(count: 1)
      end.not_to change { RateManagement::Pricelist.count }

      expect(page).to have_semantic_error('some error')
    end

    context 'when raises RateManagement::CreatePricelistItems::InvalidAttributesError' do
      let(:error) { RateManagement::CreatePricelistItems::InvalidAttributesError.new('some field with some error') }

      it 'should be raise validation error' do
        expect do
          subject
          expect(page).to have_semantic_errors(count: 1)
        end.not_to change { RateManagement::Pricelist.count }

        expect(page).to have_semantic_error('File some field with some error')
      end
    end
  end
end
