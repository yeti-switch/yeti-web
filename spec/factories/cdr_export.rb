FactoryGirl.define do
  factory :cdr_export, class: CdrExport do
    type 'Base'
    callback_url nil
    filters do
      {
        time_start_gteq: '2018-01-01',
        time_start_lteq: '2018-03-01'
      }
    end
    fields [:success, :id]
    status nil
  end
end
