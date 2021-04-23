# frozen_string_literal: true

RSpec.describe 'Filter dialpeer records', :js do
  subject do
    visit dialpeers_path
    filter_records
    within_filters { click_submit('Filter') }
  end

  include_context :login_as_admin

  let!(:other_dialpeers) { create_list :dialpeer, 2 }

  describe 'filter by tagged' do
    let(:filter_records) do
      within_filters do
        fill_in_chosen 'Tagged', with: filter_value
      end
    end

    let!(:tag) { create :routing_tag }
    let!(:dialpeer_tagged) { create :dialpeer, routing_tag_ids: [tag.id] }

    context 'with filter by tagged' do
      let(:filter_value) { 'Yes' }

      it 'returns records with any tag' do
        subject

        expect(page).to have_table
        expect(page).to have_table_row count: 1
        expect(page).to have_table_cell column: 'Id', text: dialpeer_tagged.id
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
        expect(page).to have_table_row count: other_dialpeers.count
        other_dialpeers.each { |p| expect(page).to have_css '.resource_id_link', text: p.id }
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

        let!(:dialpeer_tag_countains) { create :dialpeer, routing_tag_ids: [tags.first.id, tags.second.id] }

        it 'returns one record with routing_tag only' do
          subject

          expect(page).to have_table
          expect(page).to have_table_row count: 1
          expect(page).to have_table_cell column: 'Id', text: dialpeer_tag_countains.id
        end
      end
    end
  end

  describe 'filter by routing tags count' do
    let!(:tags) { create_list :routing_tag, 3 }
    let!(:dialpeer_tagged) { create :dialpeer, routing_tag_ids: tags.map(&:id) }

    context 'when user set negative tags count' do
      let(:filter_records) do
        within_filters do
          fill_in name: 'q[routing_tag_ids_count_equals]', with: negative_value
          expect(page).to have_field(name: 'q[routing_tag_ids_count_equals]', with: negative_value)
        end
      end

      let(:negative_value) { -2 }

      it 'shoul be return all dialpeers' do
        subject

        expect(page).to have_table
        expect(page).to have_table_row count: (other_dialpeers << dialpeer_tagged).size
        expect(page).to have_table_cell column: 'Id', text: dialpeer_tagged.id
      end
    end

    context 'when user set correct tags count' do
      let(:filter_records) do
        within_filters do
          fill_in name: 'q[routing_tag_ids_count_equals]', with: tags.size
          expect(page).to have_field(name: 'q[routing_tag_ids_count_equals]', with: tags.size)
        end
      end

      it 'shoul be return dialpeers with correct routing tags count' do
        subject

        expect(page).to have_table
        expect(page).to have_table_row count: 1
        expect(page).to have_table_cell column: 'Id', text: dialpeer_tagged.id
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
        let!(:dialpeers_with_one_tag) { create :dialpeer, routing_tag_ids: [specific_tag.id] }

        it 'should return only dialpeers with specific tag' do
          subject

          expect(page).to have_table
          expect(page).to have_table_row count: 1
          within_table_row(id: dialpeers_with_one_tag.id) do
            expect(page).to have_table_cell(column: 'Routing Tags', text: specific_tag.name)
          end
        end
      end

      context 'when there are no dialpeers wtih specified routing tags count' do
        let(:filter_records) do
          within_filters do
            fill_in name: 'q[routing_tag_ids_count_equals]', with: tags.size + 1
            expect(page).to have_field(name: 'q[routing_tag_ids_count_equals]', with: tags.size + 1)
          end
        end

        it 'shouldn`t return any rows' do
          subject

          expect(page).to_not have_table
          expect(page).to have_text('No Dialpeers found')
        end
      end
    end
  end
end
