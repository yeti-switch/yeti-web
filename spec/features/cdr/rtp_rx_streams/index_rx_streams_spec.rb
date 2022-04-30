# frozen_string_literal: true

RSpec.describe 'RX stream index', type: :feature do
  include_context :login_as_admin
  let(:index_path) { rtp_rx_streams_path }

  describe 'index' do
    it 'n+1 checks' do
      st = create_list(:rx_stream, 2)
      visit rtp_rx_streams_path
      st.each do |s|
        expect(page).to have_css('.resource_id_link', text: s.id)
      end
    end
  end

  describe 'filter' do
    subject { click_button :Filter }

    let(:record_attrs) { {} }
    let!(:record) { FactoryBot.create(:rx_stream, record_attrs) }
    let!(:second_record) { FactoryBot.create(:rx_stream) }

    context 'by RX_SSRC' do
      context 'when "Equals" option of filter is selected' do
        let(:filter_value) { 123 }
        let(:record_attrs) { { rx_ssrc: filter_value } }

        before { visit rtp_rx_streams_path(q: { rx_ssrc_equals: filter_value }) }

        it 'should render filtered records only' do
          subject

          expect(page).to have_http_status :ok
          expect(find('option[value="rx_ssrc_equals"]')).to be_selected
          expect(find('option[value="rx_ssrc_hex"]')).not_to be_selected
          expect(page).to have_table_row count: 1
          expect(page).to have_table_cell column: 'Id', text: record.id
          expect(page).to have_field 'Rx ssrc', with: filter_value.to_s
          expect(record).to have_attributes rx_ssrc: filter_value
          expect(second_record).not_to have_attributes rx_ssrc: filter_value
        end
      end

      context 'when "Hex" option of filter is selected' do
        let(:hex_filter_value) { '0x123345' }
        let(:filter_value) { 1_192_773 }
        let(:record_attrs) { { rx_ssrc: filter_value } }

        before { visit rtp_rx_streams_path(q: { rx_ssrc_hex: hex_filter_value }) }

        it 'should render filtered records only' do
          subject

          expect(page).to have_http_status :ok
          expect(find('option[value="rx_ssrc_equals"]')).not_to be_selected
          expect(find('option[value="rx_ssrc_hex"]')).to be_selected
          expect(page).to have_table_row count: 1
          expect(page).to have_table_cell column: 'Id', text: record.id
          expect(page).to have_field 'Rx ssrc', with: hex_filter_value
          expect(hex_filter_value.hex).to eq filter_value
          expect(record).to have_attributes rx_ssrc: filter_value
          expect(second_record).not_to have_attributes rx_ssrc: filter_value
        end
      end
    end
  end
end
