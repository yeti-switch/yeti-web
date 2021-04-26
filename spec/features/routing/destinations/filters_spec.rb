# frozen_string_literal: true

RSpec.describe 'Filter Destination records', :js do
  subject do
    visit destinations_path
    filter_records
    within_filters { click_submit('Filter') }
  end

  include_context :login_as_admin

  describe 'filter by tagged' do
    let!(:other_destinations_list) { create_list :destination, 2 }

    let(:filter_records) do
      within_filters do
        fill_in_chosen 'Tagged', with: filter_value
      end
    end

    let!(:tag) { create :routing_tag, :ua }
    let!(:customers_auth_tagged) { create :destination, routing_tag_ids: [tag.id] }

    context 'with filter by tagged' do
      let(:filter_value) { 'Yes' }

      it 'returns records with any tag' do
        subject

        expect(page).to have_table
        expect(page).to have_table_row count: 1
        expect(page).to have_table_cell column: 'Id', text: customers_auth_tagged.id
        within_filters do
          expect(page).to have_field_chosen('Tagged', with: filter_value)
        end
      end
    end

    context 'with filter by not tagged' do
      let(:filter_value) { 'No' }

      it 'returns record without any tag' do
        subject

        expect(page).to have_table
        expect(page).to have_table_row count: other_destinations_list.count
        other_destinations_list.each { |d| expect(page).to have_table_cell column: 'Id', text: d.id }
        within_filters do
          expect(page).to have_field_chosen('Tagged', with: filter_value)
        end
      end
    end

    describe 'filter by routing tag ids contains' do
      let(:filter_records) do
        within_filters do
          fill_in_chosen 'Routing Tag IDs Contains', with: tags.first.name, multiple: true
          fill_in_chosen 'Routing Tag IDs Contains', with: tags.second.name, multiple: true
          expect(page).to have_field_chosen('Routing Tag IDs Contains', with: tags.first.name, exact: false)
          expect(page).to have_field_chosen('Routing Tag IDs Contains', with: tags.second.name, exact: false)
        end
      end

      context '"ROUTING TAG IDS CONTAINS"' do
        let(:tags) { create_list(:routing_tag, 2) }
        let!(:destinations_tag_contains) { create :destination, routing_tag_ids: [tags.first.id, tags.second.id] }

        it 'returns one record with routing_tag only' do
          subject

          expect(page).to have_table
          expect(page).to have_table_row count: 1
          expect(page).to have_table_cell column: 'Id', text: destinations_tag_contains.id
        end
      end
    end
  end

  describe 'filter by routing for contains' do
    let!(:destination) { create :destination, prefix: 'test' }

    context 'with filter by valid value' do
      let(:filter_value) { 'test1111' }
      let(:filter_records) do
        within_filters do
          fill_in 'Routing for contains', with: filter_value
        end
      end

      it 'shoul be return one record' do
        subject

        expect(page).to have_table
        expect(page).to have_table_row count: 1
        expect(page).to have_table_cell column: 'Id', text: destination.id
        within_filters { expect(page).to have_field('Routing for contains', with: filter_value) }
      end
    end

    context 'with filter by invalid value' do
      let(:filter_value) { 'invalid_prefix' }
      let(:filter_records) do
        within_filters do
          fill_in 'Routing for contains', with: filter_value
        end
      end

      it 'shoul be return zero record' do
        subject

        expect(page).to have_text('No Destinations found')
        expect(page).to_not have_table
        within_filters { expect(page).to have_field('Routing for contains', with: filter_value) }
      end
    end
  end

  describe 'filter by routing tags count' do
    let!(:other_destinations) { create_list :destination, 2 }
    let!(:tags) { create_list :routing_tag, 3 }
    let!(:destination_tagged) { create :destination, routing_tag_ids: tags.map(&:id) }

    context 'when user set negative tags count' do
      let(:filter_records) do
        within_filters do
          fill_in name: 'q[routing_tag_ids_count_equals]', with: negative_value
          expect(page).to have_field(name: 'q[routing_tag_ids_count_equals]', with: negative_value)
        end
      end

      let(:negative_value) { -2 }

      it 'shoul be return all destinations' do
        subject

        expect(page).to have_table
        expect(page).to have_table_row count: (other_destinations << destination_tagged).size
        expect(page).to have_table_cell column: 'Id', text: destination_tagged.id
      end
    end

    context 'when user set correct tags count' do
      let(:filter_records) do
        within_filters do
          fill_in name: 'q[routing_tag_ids_count_equals]', with: tags.size
          expect(page).to have_field(name: 'q[routing_tag_ids_count_equals]', with: tags.size)
        end
      end

      it 'shoul be return destinations with correct routing tags count' do
        subject

        expect(page).to have_table
        expect(page).to have_table_row count: 1
        expect(page).to have_table_cell column: 'Id', text: destination_tagged.id
      end

      context 'when set specific routing tag cover and routing tag count' do
        let(:filter_records) do
          within_filters do
            fill_in name: 'q[routing_tag_ids_count_equals]', with: 1
            fill_in_chosen 'Routing tag ids covers', with: specific_tag.name, multiple: true
            expect(page).to have_field(name: 'q[routing_tag_ids_count_equals]', with: 1)
            expect(page).to have_field_chosen('Routing tag ids covers', with: specific_tag.name, exact: false)
          end
        end
        let!(:specific_tag) { tags.first }
        let!(:destination_with_one_tag) { create :destination, routing_tag_ids: [specific_tag.id] }

        it 'should return only destinations with specific tag' do
          subject

          expect(page).to have_table
          expect(page).to have_table_row count: 1
          within_table_row(id: destination_with_one_tag.id) do
            expect(page).to have_table_cell(column: 'Routing Tags', text: specific_tag.name)
          end
        end
      end

      context 'when there are no destinations wtih specified routing tags count' do
        let(:filter_records) do
          within_filters do
            fill_in name: 'q[routing_tag_ids_count_equals]', with: tags.size + 1
            expect(page).to have_field(name: 'q[routing_tag_ids_count_equals]', with: tags.size + 1)
          end
        end

        it 'shouldn`t return any rows' do
          subject

          expect(page).to_not have_table
          expect(page).to have_text('No Destinations found')
        end
      end
    end
  end
end
