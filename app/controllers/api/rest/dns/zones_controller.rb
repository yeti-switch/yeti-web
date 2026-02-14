# frozen_string_literal: true

class Api::Rest::Dns::ZonesController < Api::Rest::Dns::BaseController
  def zonefile
    @zone = zone
    @grouped_records = @zone.records.sort_by(&:id).group_by(&:record_type)
    zonefile_payload = ApplicationController.renderer.render(
      template: 'api/rest/dns/zones/zonefile',
      formats: [:text],
      assigns: {
        zone: @zone,
        grouped_records: @grouped_records
      }
    )

    render plain: zonefile_payload, content_type: 'text/dns'
  end

  private

  def zone
    @zone ||= Equipment::Dns::Zone.includes(:records).find(params[:id])
  end
end
