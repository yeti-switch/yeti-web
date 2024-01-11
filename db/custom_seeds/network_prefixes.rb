# frozen_string_literal: true

puts 'loading global data' # rubocop:disable Rails/Output
network_types = YAML.load_file('db/network_types.yml')
networks = YAML.load_file('db/networks.yml')
countries = YAML.load_file('db/countries.yml')
network_prefixes = YAML.load_file('db/network_prefixes.yml')

System::NetworkPrefix.transaction do
  puts 'deleting old data' # rubocop:disable Rails/Output
  System::NetworkPrefix.delete_all
  System::Network.delete_all
  System::NetworkType.delete_all
  System::Country.delete_all

  puts 'insert new global' # rubocop:disable Rails/Output
  System::NetworkType.insert_all!(network_types) if network_types.any?
  System::Network.insert_all!(networks) if networks.any?
  System::Country.insert_all!(countries) if countries.any?
  System::NetworkPrefix.insert_all!(network_prefixes) if network_prefixes.any?

  Dir.glob('db/network_data/**/*.yml') do |f|
    puts "processing file #{f}:" # rubocop:disable Rails/Output
    data = YAML.load_file(f, aliases: true)
    n = data['networks']
    System::Network.insert_all!(n) if n.any?
    puts "  loaded #{n.length} networks" # rubocop:disable Rails/Output
    n_ids = n.map { |ni| ni['id'] }.uniq

    np = data['network_prefixes']
    System::NetworkPrefix.insert_all!(np) if np.any?
    puts "  loaded #{np.length} network prefixes" # rubocop:disable Rails/Output
    np_ids = np.map { |npi| npi['network_id'] }.uniq

    no_prefixes = n_ids - np_ids
    puts "  networks without prefixes: #{no_prefixes}" if no_prefixes.any? # rubocop:disable Rails/Output
  end

  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.network_types_id_seq', MAX(id), true) FROM sys.network_types"
  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.networks_id_seq', MAX(id), true) FROM sys.networks"
  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.countries_id_seq', MAX(id), true) FROM sys.countries"
  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.network_prefixes_id_seq', MAX(id), true) FROM sys.network_prefixes"
end
