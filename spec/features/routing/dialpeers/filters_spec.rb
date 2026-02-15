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
        fill_in_tom_select 'TAGGED', with: filter_value
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
          expect(page).to have_field_tom_select('TAGGED', with: filter_value)
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
          expect(page).to have_field_tom_select('TAGGED', with: filter_value)
        end
      end
    end

    describe 'filter by routing tag ids contains' do
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
            fill_in_tom_select 'ROUTING TAG IDS COVERS', with: specific_tag.name, multiple: true
            expect(page).to have_field(name: 'q[routing_tag_ids_count_equals]', with: 1)
            expect(page).to have_field_tom_select('Routing tag ids covers', with: specific_tag.name, exact: false)
          end
        end
        let!(:specific_tag) { tags.first }
        let!(:dialpeers_with_one_tag) { create :dialpeer, routing_tag_ids: [specific_tag.id] }

        it 'should return only dialpeers with specific tag' do
          subject

          expect(page).to have_table
          expect(page).to have_table_row count: 1
          within_table_row(id: dialpeers_with_one_tag.id) do
            expect(page).to have_table_cell(column: 'Routing Tags', text: specific_tag.name.upcase)
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

  describe 'filter by initial rate' do
    let!(:dialpeer_one) { create :dialpeer, initial_rate: 1 }
    let!(:dialpeer_two) { create :dialpeer, initial_rate: 2 }
    let!(:dialpeer_three) { create :dialpeer, initial_rate: 3 }

    let(:filter_records) do
      within_filters do
        fill_in 'Initial rate', with: initial_rate_value
        expect(page).to have_field('Initial rate', with: initial_rate_value)
      end
    end

    let(:initial_rate_value) { 1 }

    it 'should be return one dialpeer' do
      subject

      expect(page).to have_table
      expect(page).to have_table_row count: 1
      expect(page).to have_table_cell column: 'Id', text: dialpeer_one.id
    end
  end

  describe 'filter by next rate' do
    let!(:dialpeer_one) { create :dialpeer, next_rate: 1 }
    let!(:dialpeer_two) { create :dialpeer, next_rate: 2 }
    let!(:dialpeer_three) { create :dialpeer, next_rate: 3 }

    let(:filter_records) do
      within_filters do
        fill_in 'Next rate', with: next_rate_value
        expect(page).to have_field('Next rate', with: next_rate_value)
      end
    end

    let(:next_rate_value) { 1 }

    it 'should be return one dialpeer' do
      subject

      expect(page).to have_table
      expect(page).to have_table_row count: 1
      expect(page).to have_table_cell column: 'Id', text: dialpeer_one.id
    end
  end

  describe 'filter by connect fee' do
    let!(:dialpeer_one) { create :dialpeer, connect_fee: 1 }
    let!(:dialpeer_two) { create :dialpeer, connect_fee: 2 }
    let!(:dialpeer_three) { create :dialpeer, connect_fee: 3 }

    let(:filter_records) do
      within_filters do
        fill_in 'Connect fee', with: connect_fee_value
        expect(page).to have_field('Connect fee', with: connect_fee_value)
      end
    end

    let(:connect_fee_value) { 1 }

    it 'should be return one dialpeer' do
      subject

      expect(page).to have_table
      expect(page).to have_table_row count: 1
      expect(page).to have_table_cell column: 'Id', text: dialpeer_one.id
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
    let!(:record) { FactoryBot.create(:dialpeer, prefix: '892715892') }

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
