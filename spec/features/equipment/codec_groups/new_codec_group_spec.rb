# frozen_string_literal: true

RSpec.describe 'Create new Codec Group', type: :feature, js: true do
  subject do
    click_submit 'Create Codec group'
  end

  include_context :login_as_admin
  let(:codec) { Codec.find_by!(name: 'G723/8000') }

  before do
    visit new_codec_group_path

    fill_in 'Name', with: 'test codec group'
    fill_in 'Ptime', with: '30'

    click_link 'Add New Codec group codec'
    within_form_has_many 'codec_group_codecs', index: 0 do
      fill_in_tom_select 'Codec', with: codec.name
    end
  end

  it 'creates record' do
    expect {
      subject
      expect(page).to have_flash_message('Codec group was successfully created.', type: :notice)
    }.to change {
      CodecGroup.count
    }.by(1)
      .and change { CodecGroupCodec.count }.by(1)

    record = CodecGroup.last!
    expect(page).to have_current_path codec_group_path(record.id)

    expect(record).to have_attributes(name: 'test codec group', ptime: 30)
    expect(record.codec_group_codecs.size).to eq(1)
    expect(record.codec_group_codecs.first).to have_attributes(
                                                 codec_id: codec.id,
                                                 priority: 100,
                                                 dynamic_payload_type: nil,
                                                 format_parameters: ''
                                               )
  end

  context 'two codecs with same priority' do
    let(:gsm_codec) { Codec.find_by!(name: 'GSM/8000') }

    before do
      fill_in 'Name', with: 'c_group_with_two_codecs'

      within_form_has_many 'codec_group_codecs', index: 0 do
        fill_in 'Priority', with: '50'
      end

      click_link 'Add New Codec group codec'
      within_form_has_many 'codec_group_codecs', index: 1 do
        fill_in_tom_select 'Codec', with: gsm_codec.name
        fill_in 'Priority', with: '50'
      end
    end

    it 'should have validations error and reload page' do
      expect {
        subject
        expect(page).to have_semantic_error("Codec Group can't contain codecs with the same priority")
      }.to change {
        CodecGroup.count
      }.by(0)
        .and change { CodecGroupCodec.count }.by(0)

      expect(page).to have_semantic_errors(count: 1)
    end
  end
end
