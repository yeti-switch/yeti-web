# frozen_string_literal: true

Rails.logger.info 'loading global data'
network_types = YAML.load_file('db/network_types.yml')
networks = YAML.load_file('db/networks.yml')
countries = YAML.load_file('db/countries.yml')
network_prefixes = YAML.load_file('db/network_prefixes.yml')

System::NetworkPrefix.transaction do
  Rails.logger.info 'deleting old data'
  System::NetworkPrefix.delete_all
  System::Network.delete_all
  System::NetworkType.delete_all
  System::Country.delete_all

  Rails.logger.info 'insert new global'
  System::NetworkType.insert_all!(network_types) if network_types.any?
  System::Network.insert_all!(networks) if networks.any?
  System::Country.insert_all!(countries) if countries.any?
  System::NetworkPrefix.insert_all!(network_prefixes) if network_prefixes.any?
end

System::NetworkPrefix.transaction do
  network_attrs_list = []
  network_prefix_attrs_list = []
  Dir.glob('db/network_data/**/*.yml') do |f|
    Rails.logger.info "load file #{f}:"
    data = YAML.load_file(f, aliases: true)
    network_attrs_list.concat(data['networks'])
    network_prefix_attrs_list.concat(data['network_prefixes'])
  end

  System::Network.insert_all!(network_attrs_list) if network_attrs_list.any?
  Rails.logger.info "  loaded #{network_attrs_list.length} networks"
  n_network_ids = network_attrs_list.map { |network_attrs| network_attrs['id'] }

  System::NetworkPrefix.insert_all!(network_prefix_attrs_list) if network_prefix_attrs_list.any?
  Rails.logger.info "  loaded #{network_prefix_attrs_list.length} network prefixes"
  np_network_ids = network_prefix_attrs_list.map { |network_prefix_attrs| network_prefix_attrs['network_id'] }.uniq

  no_prefixes = n_network_ids - np_network_ids
  Rails.logger.info "  networks without prefixes: #{no_prefixes}" if no_prefixes.any?
end

System::NetworkPrefix.transaction do
  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.network_types_id_seq', MAX(id), true) FROM sys.network_types"
  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.networks_id_seq', MAX(id), true) FROM sys.networks"
  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.countries_id_seq', MAX(id), true) FROM sys.countries"
  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.network_prefixes_id_seq', MAX(id), true) FROM sys.network_prefixes"
end
