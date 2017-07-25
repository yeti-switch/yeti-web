class ContractorSerializer < ActiveModel::Serializer
  attributes :id, :name, :enabled, :vendor, :customer, :description, :address, :phones, :smtp_connection_id
end
