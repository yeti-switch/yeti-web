# frozen_string_literal: true

Cdr::Cdr.add_partitions

20.times { Cdr::Cdr.create!(time_start: Time.now.utc) }
