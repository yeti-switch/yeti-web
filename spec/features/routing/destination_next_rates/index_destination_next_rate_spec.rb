# frozen_string_literal: true

RSpec.describe 'Index Routing Destination Next Rates', type: :feature, js: true do
  include_context :login_as_admin

  subject { visit destination_next_rates_path }

  let!(:next_rates) { FactoryBot.create_list(:destination_next_rate, 3) }

  it 'should render correct index page' do
    subject

    expect(page).to have_table_row(count: next_rates.size)
    next_rates.each do |next_rate|
      within_table_row(id: next_rate.id) do
        expect(page).to have_table_cell(column: 'Destination', exact_text: next_rate.destination.display_name)
        expect(page).to have_table_cell(column: 'Rate Group', exact_text: next_rate.destination.rate_group.display_name)
        expect(page).to have_table_cell(column: 'Applied', exact_text: 'NO')
        expect(page).to have_table_cell(column: 'Apply Time', exact_text: next_rate.apply_time.to_fs(:db))
        expect(page).to have_table_cell(column: 'Initial Rate', exact_text: next_rate.initial_rate.to_s)
        expect(page).to have_table_cell(column: 'Next Rate', exact_text: next_rate.next_rate.to_s)
        expect(page).to have_table_cell(column: 'Initial Interval', exact_text: next_rate.initial_interval.to_s)
        expect(page).to have_table_cell(column: 'Next Interval', exact_text: next_rate.next_interval.to_s)
        expect(page).to have_table_cell(column: 'Connect Fee', exact_text: next_rate.connect_fee.to_s)
        expect(page).to have_table_cell(column: 'Created At', exact_text: next_rate.created_at.to_fs(:db))
        expect(page).to have_table_cell(column: 'Updated At', exact_text: next_rate.updated_at.to_fs(:db))
        expect(page).to have_table_cell(column: 'External ID', exact_text: '')
      end
    end
  end

  describe 'filters' do
    subject do
      super()

      within_filters do
        filtering!
        click_on 'Filter'
      end
    end

    context 'by Rate Group' do
      let(:filtering!) do
        fill_in_tom_select 'RATE GROUP', with: rate_group.name
      end

      let(:record) { next_rates[0] }
      let(:rate_group) { record.destination.rate_group }

      it 'should render only filtered record' do
        subject

        expect(page).to have_table_row(count: 1)
        within_table_row(id: record.id) do
          expect(page).to have_table_cell(column: 'Rate Group', exact_text: rate_group.display_name)
        end

        within_filters do
          expect(page).to have_field_tom_select('RATE GROUP', with: rate_group.display_name)
        end
      end
    end

    context 'by Destination' do
      let(:filtering!) do
        fill_in_filter_type_tom_select 'Destination', with: filter_type
        fill_in 'Destination', with: filter_value
      end

      let(:filter_type) { 'Contains' }
      let!(:destination) { FactoryBot.create(:destination, prefix: '12385643584') }
      let!(:record) { FactoryBot.create(:destination_next_rate, destination:) }
      let(:filter_value) { '85643' }

      it 'should render only filtered record' do
        subject

        expect(page).to have_table_row(count: 1)
        within_table_row(id: record.id) do
          expect(page).to have_table_cell(column: 'Destination', exact_text: destination.display_name)
        end

        within_filters do
          expect(page).to have_field('Destination', with: filter_value)
        end
      end

      context 'when filter_type Equals' do
        let(:filter_type) { 'Equals' }
        let(:filter_value) { '12385643584' }

        it 'should render only filtered record' do
          subject

          expect(page).to have_table_row(count: 1)
          within_table_row(id: record.id) do
            expect(page).to have_table_cell(column: 'Destination', exact_text: destination.display_name)
          end

          within_filters do
            expect(page).to have_field('Destination', with: filter_value)
          end
        end
      end

      context 'when filter_type Starts with' do
        let(:filter_type) { 'Starts with' }
        let(:filter_value) { '1238564' }

        it 'should render only filtered record' do
          subject

          expect(page).to have_table_row(count: 1)
          within_table_row(id: record.id) do
            expect(page).to have_table_cell(column: 'Destination', exact_text: destination.display_name)
          end

          within_filters do
            expect(page).to have_field('Destination', with: filter_value)
          end
        end
      end

      context 'when filter_type Ends with' do
        let(:filter_type) { 'Ends with' }
        let(:filter_value) { '43584' }

        it 'should render only filtered record' do
          subject

          expect(page).to have_table_row(count: 1)
          within_table_row(id: record.id) do
            expect(page).to have_table_cell(column: 'Destination', exact_text: destination.display_name)
          end

          within_filters do
            expect(page).to have_field('Destination', with: filter_value)
          end
        end
      end
    end
  end

  describe 'batch actions' do
    subject do
      super()

      select_records!
      click_batch_action(batch_action_name)
      confirm_modal_dialog
    end

    context 'Delete' do
      let(:select_records!) do
        next_rates.each do |next_rate|
          table_select_row(next_rate.id)
        end
      end
      let(:batch_action_name) { 'Delete Selected' }
      let(:expected_next_rate_ids) { next_rates.map { |n_r| n_r.id.to_s } }

      let!(:ignored_next_rates) { FactoryBot.create_list(:destination_next_rate, 3) }

      it 'should remove selected next rates' do
        expect(DestinationNextRate::BulkDelete).to receive(:call)
          .with(next_rate_ids: match_array(expected_next_rate_ids))
          .and_call_original

        expect do
          subject

          expect(page).to have_flash_message('Selected Destination Next Rates Destroyed!', type: :notice)
        end.to change { Routing::DestinationNextRate.count }.by(-next_rates.size)

        expect(Routing::DestinationNextRate.where(id: next_rates.pluck(:id))).not_to be_exists
        expect(Routing::DestinationNextRate.where(id: ignored_next_rates.pluck(:id))).to be_exists
      end
    end
  end
end
