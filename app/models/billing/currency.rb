# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.currencies
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#  rate :float            not null
#
# Indexes
#
#  currencies_name_key  (name) UNIQUE
#
class Billing::Currency < ApplicationRecord
  self.table_name = 'billing.currencies'

  include WithPaperTrail

  NAMES = {
    'AED' => 'United Arab Emirates Dirham',
    'AFN' => 'Afghanistan Afghani',
    'ALL' => 'Albania Lek',
    'AMD' => 'Armenia Dram',
    'ANG' => 'Curaçao, Sint Maarten Netherlands Antillean Guilder',
    'AOA' => 'Angola Kwanza',
    'ARS' => 'Argentina Peso',
    'AUD' => 'Australia Dollar',
    'AWG' => 'Aruba Florin',
    'AZN' => 'Azerbaijan Manat',
    'BAM' => 'Bosnia and Herzegovina Convertible Mark',
    'BBD' => 'Barbados Dollar',
    'BDT' => 'Bangladesh Taka',
    'BGN' => 'Bulgaria Lev',
    'BHD' => 'Bahrain Dinar',
    'BIF' => 'Burundi Franc',
    'BMD' => 'Bermuda Dollar',
    'BND' => 'Brunei Dollar',
    'BOB' => 'Bolivia Boliviano',
    'BRL' => 'Brazil Real',
    'BSD' => 'Bahamas Dollar',
    'BTN' => 'Bhutan Ngultrum',
    'BWP' => 'Botswana Pula',
    'BYN' => 'Belarus Ruble',
    'BZD' => 'Belize Dollar',
    'CAD' => 'Canada Dollar',
    'CDF' => 'Democratic Republic of the Congo Franc',
    'CHF' => 'Switzerland Franc',
    'CLP' => 'Chile Peso',
    'CNY' => 'China Yuan Renminbi',
    'COP' => 'Colombia Peso',
    'CRC' => 'Costa Rica Colon',
    'CUP' => 'Cuba Peso',
    'CVE' => 'Cabo Verde Escudo',
    'CZK' => 'Czechia Koruna',
    'DJF' => 'Djibouti Franc',
    'DKK' => 'Denmark Krone',
    'DOP' => 'Dominican Republic Peso',
    'DZD' => 'Algeria Dinar',
    'EGP' => 'Egypt Pound',
    'ERN' => 'Eritrea Nakfa',
    'ETB' => 'Ethiopia Birr',
    'EUR' => 'European Union Euro',
    'FJD' => 'Fiji Dollar',
    'FKP' => 'Falkland Islands Pound',
    'GBP' => 'United Kingdom Pound Sterling',
    'GEL' => 'Georgia Lari',
    'GHS' => 'Ghana Cedi',
    'GIP' => 'Gibraltar Pound',
    'GMD' => 'Gambia Dalasi',
    'GNF' => 'Guinea Franc',
    'GTQ' => 'Guatemala Quetzal',
    'GYD' => 'Guyana Dollar',
    'HKD' => 'Hong Kong Dollar',
    'HNL' => 'Honduras Lempira',
    'HTG' => 'Haiti Gourde',
    'HUF' => 'Hungary Forint',
    'IDR' => 'Indonesia Rupiah',
    'ILS' => 'Israel New Sheqel',
    'INR' => 'India Rupee',
    'IQD' => 'Iraq Dinar',
    'IRR' => 'Iran Rial',
    'ISK' => 'Iceland Krona',
    'JMD' => 'Jamaica Dollar',
    'JOD' => 'Jordan Dinar',
    'JPY' => 'Japan Yen',
    'KES' => 'Kenya Shilling',
    'KGS' => 'Kyrgyzstan Som',
    'KHR' => 'Cambodia Riel',
    'KMF' => 'Comoros Franc',
    'KPW' => 'North Korea Won',
    'KRW' => 'South Korea Won',
    'KWD' => 'Kuwait Dinar',
    'KYD' => 'Cayman Islands Dollar',
    'KZT' => 'Kazakhstan Tenge',
    'LAK' => 'Laos Kip',
    'LBP' => 'Lebanon Pound',
    'LKR' => 'Sri Lanka Rupee',
    'LRD' => 'Liberia Dollar',
    'LSL' => 'Lesotho Loti',
    'LYD' => 'Libya Dinar',
    'MAD' => 'Morocco Dirham',
    'MDL' => 'Moldova Leu',
    'MGA' => 'Madagascar Ariary',
    'MKD' => 'North Macedonia Denar',
    'MMK' => 'Myanmar Kyat',
    'MNT' => 'Mongolia Tugrik',
    'MOP' => 'Macau Pataca',
    'MRU' => 'Mauritania Ouguiya',
    'MUR' => 'Mauritius Rupee',
    'MVR' => 'Maldives Rufiyaa',
    'MWK' => 'Malawi Kwacha',
    'MXN' => 'Mexico Peso',
    'MYR' => 'Malaysia Ringgit',
    'MZN' => 'Mozambique Metical',
    'NAD' => 'Namibia Dollar',
    'NGN' => 'Nigeria Naira',
    'NIO' => 'Nicaragua Cordoba Oro',
    'NOK' => 'Norway Krone',
    'NPR' => 'Nepal Rupee',
    'NZD' => 'New Zealand Dollar',
    'OMR' => 'Oman Rial',
    'PAB' => 'Panama Balboa',
    'PEN' => 'Peru Sol',
    'PGK' => 'Papua New Guinea Kina',
    'PHP' => 'Philippines Peso',
    'PKR' => 'Pakistan Rupee',
    'PLN' => 'Poland Zloty',
    'PYG' => 'Paraguay Guarani',
    'QAR' => 'Qatar Riyal',
    'RON' => 'Romania Leu',
    'RSD' => 'Serbia Dinar',
    'RWF' => 'Rwanda Franc',
    'SAR' => 'Saudi Arabia Riyal',
    'SBD' => 'Solomon Islands Dollar',
    'SCR' => 'Seychelles Rupee',
    'SDG' => 'Sudan Pound',
    'SEK' => 'Sweden Krona',
    'SGD' => 'Singapore Dollar',
    'SHP' => 'Saint Helena Pound',
    'SLE' => 'Sierra Leone Leone',
    'SOS' => 'Somalia Shilling',
    'SRD' => 'Suriname Dollar',
    'SSP' => 'South Sudan Pound',
    'STN' => 'São Tomé and Príncipe Dobra',
    'SYP' => 'Syria Pound',
    'SZL' => 'Eswatini Lilangeni',
    'THB' => 'Thailand Baht',
    'TJS' => 'Tajikistan Somoni',
    'TMT' => 'Turkmenistan Manat',
    'TND' => 'Tunisia Dinar',
    'TOP' => 'Tonga Pa\'anga',
    'TRY' => 'Türkiye Lira',
    'TTD' => 'Trinidad and Tobago Dollar',
    'TWD' => 'Taiwan Dollar',
    'TZS' => 'Tanzania Shilling',
    'UAH' => 'Ukraine Hryvnia',
    'UGX' => 'Uganda Shilling',
    'USD' => 'United States Dollar',
    'UYU' => 'Uruguay Peso',
    'UZS' => 'Uzbekistan Sum',
    'VES' => 'Venezuela Bolívar Soberano',
    'VND' => 'Viet Nam Dong',
    'VUV' => 'Vanuatu Vatu',
    'WST' => 'Samoa Tala',
    'XAF' => 'Central African CFA Franc BEAC',
    'XCD' => 'East Caribbean Dollar',
    'XOF' => 'West African CFA Franc BCEAO',
    'XPF' => 'French Overseas Territories CFP Franc',
    'YER' => 'Yemen Rial',
    'ZAR' => 'South Africa Rand',
    'ZMW' => 'Zambia Kwacha',
    'ZWL' => 'Zimbabwe Dollar'
  }.freeze

  validates :name, presence: true, uniqueness: true, inclusion: { in: NAMES.keys }
  validates :rate, presence: true, numericality: { greater_than: 0 }
  validate :rate_must_be_one_for_default

  has_many :accounts, class_name: 'Account', foreign_key: :currency_id, dependent: :restrict_with_error

  after_update :update_accounts_currency_name, if: :saved_change_to_name?
  after_update :update_dialpeers_currency_rate, if: :saved_change_to_rate?
  before_destroy :prevent_default_destroy

  def default?
    id == 0
  end

  def display_name
    name
  end

  private

  def rate_must_be_one_for_default
    errors.add(:rate, 'must be 1 for default currency') if default? && rate != 1
  end

  def update_accounts_currency_name
    accounts.update_all(currency_name: name)
  end

  def update_dialpeers_currency_rate
    Dialpeer.where(currency_id: id).update_all(
      "currency_rate = #{rate}, next_rate_system_currency = next_rate * #{rate}"
    )
  end

  def prevent_default_destroy
    if default?
      errors.add(:base, 'Default currency cannot be deleted')
      throw(:abort)
    end
  end
end
