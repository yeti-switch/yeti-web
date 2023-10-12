# frozen_string_literal: true

network_types = YAML.load_file('db/network_types.yml')
networks = YAML.load_file('db/networks.yml')
countries = YAML.load_file('db/countries.yml')
network_prefixes = YAML.load_file('db/network_prefixes.yml')

System::NetworkPrefix.transaction do
  System::NetworkPrefix.delete_all
  System::Network.delete_all
  System::NetworkType.delete_all
  System::Country.delete_all

  System::NetworkType.insert_all!(network_types) if network_types.any?
  System::Network.insert_all!(networks) if networks.any?
  System::Country.insert_all!(countries) if countries.any?
  System::NetworkPrefix.insert_all!(network_prefixes) if network_prefixes.any?

  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.network_types_id_seq', MAX(id), true) FROM sys.network_types"
  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.networks_id_seq', MAX(id), true) FROM sys.networks"
  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.countries_id_seq', MAX(id), true) FROM sys.countries"
  SqlCaller::Yeti.execute "SELECT pg_catalog.setval('sys.network_prefixes_id_seq', MAX(id), true) FROM sys.network_prefixes"
end
