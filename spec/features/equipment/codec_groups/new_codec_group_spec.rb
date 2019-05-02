# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Codec Group', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for CodecGroup, 'new'
  include_context :login_as_admin

  let(:codec) { Codec.find_by!(name: 'G723/8000') }

  before do
    visit new_codec_group_path

    aa_form.set_text 'Name', 'test codec group'
    aa_form.add_has_many('Codec group codec')
    aa_form.within_has_many('Codec group codec') do
      aa_form.select_chosen 'Codec', codec.name
    end
  end

  it 'creates record' do
    subject
    record = CodecGroup.last
    expect(record).to be_present
    expect(record).to have_attributes(name: 'test codec group')
    expect(record.codec_group_codecs.size).to eq(1)
    expect(record.codec_group_codecs.first).to have_attributes(
      codec_id: codec.id,
      priority: 100,
      dynamic_payload_type: nil,
      format_parameters: ''
    )
  end

  include_examples :changes_records_qty_of, CodecGroup, by: 1
  include_examples :changes_records_qty_of, CodecGroupCodec, by: 1
  include_examples :shows_flash_message, :notice, 'Codec group was successfully created.'
end
