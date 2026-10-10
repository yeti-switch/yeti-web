# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications.contacts
# Database name: primary
#
#  id            :integer(4)       not null, primary key
#  email         :string           not null
#  notes         :string
#  created_at    :timestamptz
#  updated_at    :timestamptz
#  admin_user_id :integer(4)
#  contractor_id :integer(4)
#
# Indexes
#
#  contacts_contractor_id_idx  (contractor_id)
#
# Foreign Keys
#
#  contacts_admin_user_id_fkey  (admin_user_id => admin_users.id)
#  contacts_contractor_id_fkey  (contractor_id => contractors.id)
#
RSpec.describe Billing::Contact, type: :model do
  describe 'validations' do
    subject { FactoryBot.build(:contact, email: email) }

    context 'with valid email' do
      let(:email) { 'user@example.com' }

      it { is_expected.to be_valid }
    end

    ['', '   ', 'not an address', 'user@', 'a@x.com, b@y.com'].each do |invalid_email|
      context "with email #{invalid_email.inspect}" do
        let(:email) { invalid_email }

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe '#destroy' do
    subject do
      contact.destroy!
    end

    let!(:contact) { FactoryBot.create(:contact) }
    let!(:other_contact) { FactoryBot.create(:contact) }
    let(:send_to) { [contact.id, other_contact.id] }
    let!(:schedulers) do
      [
        FactoryBot.create(:customer_traffic_scheduler, send_to: send_to),
        FactoryBot.create(:vendor_traffic_scheduler, send_to: send_to),
        FactoryBot.create(:custom_cdr_scheduler, send_to: send_to),
        FactoryBot.create(:interval_cdr_scheduler, send_to: send_to)
      ]
    end

    it 'removes contact from report schedulers' do
      subject
      expect(schedulers.map { |s| s.reload.send_to }).to all(eq([other_contact.id]))
    end

    context 'when report scheduler is invalid' do
      before { schedulers.first.update_columns(customer_id: 999_999) }

      it 'removes contact from report schedulers' do
        subject
        expect(schedulers.map { |s| s.reload.send_to }).to all(eq([other_contact.id]))
      end
    end
  end
end
