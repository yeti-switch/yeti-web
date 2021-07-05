# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.jobs
#
#  id             :bigint(8)        not null, primary key
#  last_duration  :decimal(, )
#  last_exception :string
#  last_run_at    :datetime
#  name           :string           not null
#
RSpec.describe CronJobInfo, '#update' do
  subject do
    record.update(update_params)
  end

  let!(:record) { CronJobInfo.find_by!(name: 'CallsMonitoring') }
  let(:update_params) do
    {
      last_run_at: 1.minute.ago.change(usec: 0),
      last_duration: 50.123,
      last_exception: nil
    }
  end

  context 'without last_exception' do
    it 'updates record' do
      subject
      expect(record.errors).to be_empty
      expect(subject).to eq(true)
      expect(record.reload).to have_attributes(update_params)
    end
  end

  context 'with last_exception' do
    let(:update_params) do
      super().merge last_exception: "some string\nmulti line"
    end

    it 'updates record' do
      subject
      expect(record.errors).to be_empty
      expect(subject).to eq(true)
      expect(record.reload).to have_attributes(update_params)
    end
  end
end
