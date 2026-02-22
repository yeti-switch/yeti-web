# frozen_string_literal: true

RSpec.describe 'Filter Destination records', :js do
  subject do
    visit destinations_path(visit_params)
    filter_records_and_submit!
  end

  let(:visit_params) { {} }
  let(:filter_records_and_submit!) do
    filter_records
    within_filters { click_submit('Filter') }
  end

  include_context :login_as_admin

  context 'filter by tagged' do
    let!(:other_destinations_list) { create_list :destination, 2 }

    let(:filter_records) do
      within_filters do
        fill_in_tom_select 'TAGGED', with: filter_value
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
          expect(page).to have_field_tom_select('TAGGED', with: filter_value)
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
          expect(page).to have_field_tom_select('TAGGED', with: filter_value)
        end
      end
    end

    context 'filter by routing tag ids contains' do
      let(:filter_records) do
        within_filters do
          fill_in_tom_select 'ROUTING TAG IDS CONTAINS', with: tags.first.name, multiple: true
          fill_in_tom_select 'ROUTING TAG IDS CONTAINS', with: tags.second.name, multiple: true
          expect(page).to have_field_tom_select('ROUTING TAG IDS CONTAINS', with: tags.first.name, exact: false)
          expect(page).to have_field_tom_select('ROUTING TAG IDS CONTAINS', with: tags.second.name, exact: false)
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

  context 'filter by routing for contains' do
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

  context 'filter by routing tags count' do
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
            fill_in_tom_select 'ROUTING TAG IDS COVERS', with: specific_tag.name, multiple: true
            expect(page).to have_field(name: 'q[routing_tag_ids_count_equals]', with: 1)
            expect(page).to have_field_tom_select('ROUTING TAG IDS COVERS', with: specific_tag.name, exact: false)
          end
        end
        let!(:specific_tag) { tags.first }
        let!(:destination_with_one_tag) { create :destination, routing_tag_ids: [specific_tag.id] }

        it 'should return only destinations with specific tag' do
          subject

          expect(page).to have_table
          expect(page).to have_table_row count: 1
          within_table_row(id: destination_with_one_tag.id) do
            expect(page).to have_table_cell(column: 'Routing Tags', text: specific_tag.name.upcase)
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

  context 'when query has filter by routing_tag_ids_covers' do
    let(:filter_records_and_submit!) {}
    let(:visit_params) { { q: { routing_tag_ids_covers: filter_value } } }

    context 'when filter by valid routing tag ids' do
      let(:filter_value) { [tags.first.id.to_s, tags.third.id.to_s] }

      let!(:tags) do
        [create(:routing_tag, :ua), create(:routing_tag, :us), create(:routing_tag, name: 'test')]
      end
      let!(:destination) { create(:destination, destination_attrs) }
      let(:destination_attrs) do
        {
          routing_tag_ids: tags.map(&:id),
          routing_tag_mode_id: Routing::RoutingTagMode::MODE_OR
        }
      end
      before { create(:destination) }

      it 'returns correct records' do
        subject

        expect(page).to have_table
        expect(page).to have_table_row count: 1
        expect(page).to have_table_cell column: 'Id', text: destination.id
        within_filters do
          expect(page).to have_field_tom_select('ROUTING TAG IDS COVERS', with: tags.first.name)
          expect(page).to have_field_tom_select('ROUTING TAG IDS COVERS', with: tags.third.name)
        end
      end
    end

    context 'when filter by invalid routing tag id' do
      let(:filter_value) { ['1], routing_tag_mode_id)>0; SELECT * FROM class4.destinations '] }
      before { create(:destination) }

      it 'returns empty table' do
        subject

        expect(page).to_not have_table
        expect(page).to have_text 'No Destinations found'
      end
    end

    context 'when filter by huge tag id number' do
      let(:filter_value) { ['999999999999999999999999999999999999999999999'] }
      before { create(:destination) }

      it 'returns empty table' do
        subject

        expect(page).to_not have_table
        expect(page).to have_text 'No Destinations found'
      end
    end
  end

  context 'filter by Rateplan', js: false do
    subject { click_button :Filter }

    let!(:rate_group) { FactoryBot.create(:rate_group) }
    let!(:rate_group_second) { FactoryBot.create(:rate_group) }
    let!(:rateplan) { FactoryBot.create(:rateplan, rate_groups: [rate_group, rate_group_second]) }
    let!(:record) { FactoryBot.create(:destination, rate_group:) }

    before do
      visit destinations_path
      select rateplan.name, from: 'Rateplan'
    end

    it 'should render filtered records only' do
      subject

      expect(page).to have_table_row count: 1
      expect(page).to have_table_cell column: 'Id', exact_text: record.id.to_s
    end
  end

  describe 'filter by network type' do
    let(:filter_records) do
      within_filters do
        fill_in_tom_select 'NETWORK TYPE', with: network_type.name
      end
    end

    let!(:network_type) { FactoryBot.create(:network_type) }
    let!(:network) { FactoryBot.create(:network, network_type:) }
    let!(:network_prefix) { FactoryBot.create(:network_prefix, prefix: '892715892', network:) }
    let!(:record) { FactoryBot.create(:destination, prefix: '892715892') }

    before do
      FactoryBot.create_list(:destination, 3)
    end

    it 'should be return filtered record' do
      subject

      expect(page).to have_table_row(count: 1)
      expect(page).to have_table_row(id: record.id)

      within_filters do
        expect(page).to have_field_tom_select('NETWORK TYPE', with: network_type.name)
      end
    end
  end
end
