# frozen_string_literal: true

RSpec.describe 'Filtering the Area Prefix records', type: :feature do
  include_context :login_as_admin

  subject do
    visit routing_area_prefixes_path
    filter_area_prefix_records
    within_filters { click_submit('Filter') }
  end

  let(:filter_value) { nil }

  context 'filter by :prefix_covers' do
    let(:area) { FactoryBot.create(:area) }
    let!(:area_prefixes) {
      [
        FactoryBot.create(:area_prefix, area: area, prefix: '12'),
        FactoryBot.create(:area_prefix, area: area, prefix: '1234'),
        FactoryBot.create(:area_prefix, area: area, prefix: '123456')
      ]
    }

    let(:filter_area_prefix_records) do
      within_filters { fill_in 'Prefix covers', with: filter_value }
    end

    context 'when filtering by value 1' do
      let(:filter_value) { '1' }

      it 'should not return any records' do
        subject
        expect(page).not_to have_table
        expect(page).to have_table_row(count: 0)
      end
    end

    context 'when filtering by value 12' do
      let(:filter_value) { '12' }

      it 'should filtered records by covered prefix with 12' do
        subject
        expect(page).to have_table
        expect(page).to have_table_row(count: 1)
        area_prefixes.take(1).each do |area_prefix|
          within_table_row(id: area_prefix.id) do
            expect(page).to have_table_cell(column: 'Id', text: area_prefix.id)
            expect(page).to have_table_cell(column: 'Prefix', text: area_prefix.prefix)
          end
        end
      end
    end

    context 'when filtering by value 1234' do
      let(:filter_value) { '1234' }

      it 'should filtered records by covered prefix with 1234' do
        subject
        expect(page).to have_table
        expect(page).to have_table_row(count: 2)
        area_prefixes.take(2).each do |area_prefix|
          within_table_row(id: area_prefix.id) do
            expect(page).to have_table_cell(column: 'Id', text: area_prefix.id)
            expect(page).to have_table_cell(column: 'Prefix', text: area_prefix.prefix)
          end
        end
      end
    end

    context 'when filtering by value 123456' do
      let(:filter_value) { '123456' }

      it 'should filtered records by covered prefix with 123456' do
        subject
        expect(page).to have_table
        expect(page).to have_table_row(count: 3)
        area_prefixes.each do |area_prefix|
          within_table_row(id: area_prefix.id) do
            expect(page).to have_table_cell(column: 'Id', text: area_prefix.id)
            expect(page).to have_table_cell(column: 'Prefix', text: area_prefix.prefix)
          end
        end
      end
    end

    context 'when filtering by value 123456789' do
      let(:filter_value) { '123456789' }

      it 'should filtered records by covered prefix with 123456789' do
        subject
        expect(page).to have_table
        expect(page).to have_table_row(count: 3)
        area_prefixes.each do |area_prefix|
          within_table_row(id: area_prefix.id) do
            expect(page).to have_table_cell(column: 'Id', text: area_prefix.id)
            expect(page).to have_table_cell(column: 'Prefix', text: area_prefix.prefix)
          end
        end
      end
    end
  end
end
