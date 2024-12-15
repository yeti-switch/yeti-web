# frozen_string_literal: true

RSpec.describe 'switch22.load_incoming_auth' do
  subject do
    SqlCaller::Yeti.select_all(sql).map(&:deep_symbolize_keys)
  end

  let(:sql) do
    'SELECT * FROM switch22.load_incoming_auth()'
  end

  let!(:gws_with_auth) do
    [
      create(:gateway,
             incoming_auth_username: 'r',
             incoming_auth_password: 'p'),
      create(:gateway,
             incoming_auth_allow_jwt: true),
      create(:gateway,
             incoming_auth_username: 'r1',
             incoming_auth_password: 'p1',
             incoming_auth_allow_jwt: true)
    ]
  end

  let!(:gws_without_auth) do
    [
      create(:gateway),
      create(:gateway)
    ]
  end

  it 'responds with correct rows' do
    expect(subject).to match_array(
                         gws_with_auth.map do |c|
                           {
                             id: c.id,
                             username: c.incoming_auth_username,
                             password: c.incoming_auth_password,
                             allow_jwt_auth: c.incoming_auth_allow_jwt,
                             jwt_gid: c.id.to_s
                           }
                         end
                       )
  end
end
