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
    let!(:tag) { create :routing_tag }
    let!(:dialpeer_tagged) { create :dialpeer, routing_tag_ids: [tag.id] }

    context 'with filter by tagged' do
      let(:filter_records) do
        within_filters do
          fill_in_chosen 'Tagged', with: filter_value
        end
      end

      let(:filter_value) { 'Yes' }

      it 'returns records with any tag' do
        subject

        expect(page).to have_table
        expect(page).to have_table_row count: 1
        expect(page).to have_table_cell column: 'Id', text: dialpeer_tagged.id
        expect(page).to have_field_chosen('Tagged', with: 'Yes')
      end
    end

    context 'with filter by not tagged' do
      let(:filter_records) do
        within_filters do
          fill_in_chosen 'Tagged', with: filter_value
        end
      end

      let(:filter_value) { 'No' }

      it 'returns record without any tag' do
        subject

        expect(page).to have_table
        expect(page).to have_table_row count: other_dialpeers.count
        other_dialpeers.each { |p| expect(page).to have_css '.resource_id_link', text: p.id }
        expect(page).to have_field_chosen('Tagged', with: 'No')
      end
    end

    describe 'filter by routing tag ids contains' do
      context '"ROUTING TAG IDS CONTAINS"' do
        let(:tags) { create_list(:routing_tag, 2) }

        let!(:dialpeer_tag_countains) { create :dialpeer, routing_tag_ids: [tags.first.id, tags.second.id] }

        let(:filter_records) do
          within_filters do
            fill_in_chosen 'Routing Tag IDs Contains', with: tags.first.name, multiple: true
            fill_in_chosen 'Routing Tag IDs Contains', with: tags.second.name, multiple: true
          end
        end

        it 'returns one record with routing_tag only' do
          subject

          expect(page).to have_table
          expect(page).to have_table_row count: 1
          expect(page).to have_table_cell column: 'Id', text: dialpeer_tag_countains.id
          expect(page).to have_field_chosen('Routing Tag IDs Contains', with: tags.first.name, exact: false)
          expect(page).to have_field_chosen('Routing Tag IDs Contains', with: tags.second.name, exact: false)
        end
      end
    end
  end
end
