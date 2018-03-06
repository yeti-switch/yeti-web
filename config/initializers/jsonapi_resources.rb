JSONAPI.configure do |config|
  #can be paged, offset, none (default)
  config.default_paginator = :none
  config.default_page_size = 50
  config.maximum_page_size = 1_000
  config.top_level_meta_include_record_count = true
  config.top_level_meta_record_count_key = :total_count
end
