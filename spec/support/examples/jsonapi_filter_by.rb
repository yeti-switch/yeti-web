RSpec.shared_examples :jsonapi_filter_by do |attr_name|
  let(:subject_record) { raise 'Define' }
  let(:attr_value) { raise 'Define' }

  before do
    subject_record
  end

  it 'returns only one expected record' do
    get :index, params: { filter: { attr_name => attr_value } }

    expect(response_data).to match_array(
      [
        hash_including('id' => subject_record.id.to_s)
      ]
    )
  end
end
