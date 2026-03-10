# frozen_string_literal: true

require 'cdr_processor/cdr_db'
require 'cdr_processor/primary_db'
require 'cdr_processor/json_coder'
require 'cdr_processor/json_each_row_coder'
require 'cdr_processor/event_filter'
require 'cdr_processor/amqp_factory'
require 'cdr_processor/api'
require 'cdr_processor/event'
require 'cdr_processor/consumer_base'
require 'cdr_processor/consumer'
require 'cdr_processor/consumer_group'
require 'cdr_processor/worker'
require 'cdr_processor/processors/cdr_billing'
require 'cdr_processor/processors/cdr_stat'
require 'cdr_processor/processors/cdr_http_base'
require 'cdr_processor/processors/cdr_http'
require 'cdr_processor/processors/cdr_http_batch'
require 'cdr_processor/processors/cdr_amqp'
require 'cdr_processor/processors/cdr_clickhouse'

CdrProcessor::CdrDb.extend(CdrProcessor::Api)
