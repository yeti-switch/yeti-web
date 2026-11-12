# frozen_string_literal: true

module CurrencyRates
  module Providers
    # Central bank tables served by https://allratestoday.com, one bank
    # per installation: set currency_rates.central_bank_code in yeti_web.yml
    # (e.g. bcb for Brazil). The endpoint has no history, it always returns the
    # bank's latest published table.
    #
    # Rows are { base, quote, type, value }, where 1 base = value quote. Banks
    # differ in orientation (USD/BRL at bcb, EUR/USD at ecb), so the home
    # currency is the one that appears in most pairs. A pair can have several
    # rows: the published mid rate is used, otherwise the mean of a buy and sell
    # quote. Period averages are skipped, they are not a current rate.
    class AllRatesToday < CrossRateBase
      LABEL = 'AllRatesToday'
      DEFAULT_URL = 'https://allratestoday.com'
      PATH = '/api/open/central-bank'

      MID_RATE_TYPES = %w[reference middle official indicative close spot informational].freeze
      BUY_SELL_TYPES = [%w[buy sell], %w[tt_buy tt_sell]].freeze

      private

      def rates_url
        raise Error, "#{label} requires currency_rates.central_bank_code in yeti_web.yml" if bank_code.blank?

        "#{(config&.central_bank_url.presence || DEFAULT_URL).chomp('/')}#{PATH}/#{bank_code}"
      end

      def bank_code
        config&.central_bank_code
      end

      def home_quotes(data)
        raise Error, "#{label} table for #{bank_code} is stale, last published #{data['rate_date']}" if data['stale']

        pairs = data.fetch('rates').group_by { |row| row.values_at('base', 'quote') }
                    .transform_values { |rows| mid_rate(rows) }.compact
        home = pairs.keys.flatten.tally.max_by(&:last)&.first
        raise Error, "#{label} table for #{bank_code} has no usable rates" if home.nil?

        pairs.each_with_object(home => 1.0) do |((base, quote), value), quotes|
          quotes[base] = value if quote == home
          quotes[quote] = 1.0 / value if base == home
        end
      end

      def mid_rate(rows)
        values = rows.to_h { |row| [row.fetch('type'), row.fetch('value').to_f] }
        rate = values.values_at(*MID_RATE_TYPES).compact.first
        rate ||= buy_sell_mean(values)
        rate if rate&.positive?
      end

      def buy_sell_mean(values)
        buy, sell = BUY_SELL_TYPES.find { |types| types.all? { |type| values.key?(type) } }
        (values[buy] + values[sell]) / 2 if buy
      end
    end
  end
end
