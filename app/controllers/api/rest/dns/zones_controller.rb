# frozen_string_literal: true

class Api::Rest::Dns::ZonesController < ::Api::RestController
  before_action :find_zone, only: :file
  def index
    rows = Equipment::Dns::Zone.select(:id, :name, :serial)
    render json: rows, status: 200
  end

  def show
    render plain: 'HUI'
  end

  def file
    template = '
$ORIGIN .
$TTL @zone.ttl
<%= @zone.name %>. IN  SOA <%= @zone.soa_mname %> <%= @zone.soa_rname %> <%= @zone.serial %> <%= @zone.refresh %> <%= @zone.retry %> <%= @zone.expire %> <%= @zone.minimum %>

% @zone.records.each do |r|
<%= r.name %> <%= r.content %>
% end
'

    tpl = ERB.new(template)
    render plain: tpl.result(binding), status: 200
  end

  private

  # possible security issue
  def find_zone
    @zone = Equipment::Dns::Zone.find(Integer(params[:id]))
  end
end
