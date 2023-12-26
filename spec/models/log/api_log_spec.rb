# frozen_string_literal: true

# == Schema Information
#
# Table name: logs.api_requests
#
#  id               :bigint(8)        not null, primary key
#  action           :string
#  controller       :string
#  db_duration      :float
#  meta             :jsonb
#  method           :string
#  page_duration    :float
#  params           :text
#  path             :string
#  remote_ip        :inet
#  request_body     :text
#  request_headers  :text
#  response_body    :text
#  response_headers :text
#  status           :integer(4)
#  created_at       :timestamptz      not null
#
# Indexes
#
#  api_requests_created_at_idx  (created_at)
#  api_requests_id_idx          (id)
#

RSpec.describe Log::ApiLog do
  describe '.create' do
    subject do
      FactoryBot.create(:api_log)
    end

    it 'creates api_log' do
      expect { subject }.to change { described_class.count }.by(1)
      expect(subject).to be_persisted
      expect(subject.errors).to be_empty
    end
  end

  describe '.remote_ip_inet' do
    subject { described_class.remote_ip_eq_inet(scope_value) }

    let(:scope_value) { nil }

    context 'when invalid IP address' do
      let(:scope_value) { '127.0.0.' }

      it 'should return empty relation' do
        expect(subject).to be_empty
      end
    end

    context 'when invalid string' do
      let(:scope_value) { 'invalid' }

      it 'should return empty relation' do
        expect(subject).to be_empty
      end
    end

    context 'when valid IP address' do
      before { Log::ApiLog.delete_all }

      let(:scope_value) { '127.0.0.1' }
      let!(:record) { FactoryBot.create(:api_log, remote_ip: '127.0.0.1') }
      let(:second_record) { FactoryBot.create(:api_log, remote_ip: '80.80.123.23') }

      it 'should return filtered record only' do
        expect(subject).to contain_exactly(record)
      end
    end
  end
end
