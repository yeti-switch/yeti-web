# frozen_string_literal: true

FactoryBot.define do
  factory :not_authenticated, class: Report::Realtime::NotAuthenticated, parent: :cdr do
    time_start { 110.seconds.ago.utc } # this record will be available in page during 10 second
    auth_orig_ip { IPAddr.new(rand(2**32), Socket::AF_INET) }
    customer_auth_id { nil }
  end
end
