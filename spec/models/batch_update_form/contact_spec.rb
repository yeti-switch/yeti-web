# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Contact do
  let(:email_err_message) { I18n.t('activerecord.errors.models.billing\contact.attributes.email') }
  let!(:contractor) { FactoryBot.create :contractor, vendor: true }
  let!(:admin_user) { FactoryBot.create :admin_user }
  let!(:assign_params) do
    {
      contractor_id: contractor.id,
      admin_user_id: admin_user.id,
      email: 'example@gmail.com',
      notes: 'notes'
    }
  end

  subject do
    form = described_class.new(assign_params)
    form.valid?
    form
  end

  describe 'validation' do
    it 'should be valid' do expect(subject).to be_valid end
    it { is_expected.to allow_value('test@test.com').for :email }
    it { is_expected.to_not allow_value('string', 'string@string', 'string.string').for(:email).with_message(email_err_message) }
    it { is_expected.to_not allow_value('', ' ').for(:email) }
  end
end
