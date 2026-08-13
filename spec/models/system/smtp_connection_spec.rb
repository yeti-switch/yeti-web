# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.smtp_connections
# Database name: primary
#
#  id            :integer(4)       not null, primary key
#  auth_password :string
#  auth_type     :string           default("plain"), not null
#  auth_user     :string
#  from_address  :string           not null
#  global        :boolean          default(TRUE), not null
#  host          :string           not null
#  name          :string           not null
#  port          :integer(4)       default(25), not null
#
# Indexes
#
#  smtp_connections_name_key  (name) UNIQUE
#
RSpec.describe System::SmtpConnection do
  describe '#delivery_options' do
    subject { smtp_connection.delivery_options }

    let(:smtp_connection) do
      FactoryBot.create(:smtp_connection, host: 'smtp.example.com', port: 2525, **credentials)
    end

    context 'with credentials' do
      let(:credentials) { { auth_user: 'user', auth_password: 'secret', auth_type: 'login' } }

      it 'asks for SMTP-AUTH with the configured mechanism' do
        expect(subject).to eq(
          address: 'smtp.example.com',
          port: 2525,
          user_name: 'user',
          password: 'secret',
          authentication: :login
        )
      end
    end

    # auth_type is NOT NULL and defaults to 'plain', so a connection that uses
    # no authentication still carries one. Passing it on would make net-smtp
    # >= 0.5.0 raise "SMTP-AUTH requested but missing user name" before it even
    # opens the socket, which is what broke every credential-less connection
    # when the Rails 8 upgrade moved net-smtp from 0.3.4 to 0.5.1.
    context 'without credentials' do
      let(:credentials) { { auth_user: '', auth_password: '', auth_type: 'plain' } }

      it 'does not request authentication at all' do
        expect(subject).to eq(address: 'smtp.example.com', port: 2525)
        expect(subject).not_to have_key(:authentication)
      end
    end

    context 'when only the user is filled in' do
      let(:credentials) { { auth_user: 'user', auth_password: '', auth_type: 'plain' } }

      it 'still requests authentication, leaving net-smtp to reject the half-filled pair' do
        expect(subject).to eq(
          address: 'smtp.example.com',
          port: 2525,
          user_name: 'user',
          authentication: :plain
        )
      end
    end
  end
end
