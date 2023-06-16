# frozen_string_literal: true

RSpec.describe 'Index Log Logic Log', type: :feature do
  include_context :login_as_admin

  subject { visit logic_logs_path }

  let!(:logic_logs) do
    [
      FactoryBot.create(:logic_log),
      FactoryBot.create(:logic_log, msg: '1' * 105)
    ]
  end

  it 'should correct render table' do
    subject

    logic_logs.each do |logic_log|
      expect(page).to have_table_cell(column: 'ID', exact_text: logic_log.id.to_s)
      expect(page).to have_table_cell(column: 'Txid', exact_text: logic_log.txid.to_s)
      expect(page).to have_table_cell(column: 'Level', exact_text: logic_log.level.to_s)
      expect(page).to have_table_cell(column: 'Source', exact_text: logic_log.source)

      msg = logic_log.msg.length > 100 ? logic_log.msg[0...100] << '...' : logic_log.msg
      expect(page).to have_table_cell(column: 'Msg', exact_text: msg)
    end
  end
end
