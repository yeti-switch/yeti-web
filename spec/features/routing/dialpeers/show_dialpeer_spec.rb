# frozen_string_literal: true

RSpec.describe 'Show Dialpeer', type: :feature, js: true do
  include_context :login_as_admin

  subject do
    visit dialpeer_path(dialpeer.id)
    fill_filters!
  end

  let(:fill_filters!) { nil }
  let!(:vendor) { FactoryBot.create(:vendor) }
  let!(:gateway) { FactoryBot.create(:gateway, contractor: vendor) }
  let!(:routing_tags) do
    FactoryBot.create_list(:routing_tag, 5)
  end
  let!(:dialpeer) { create(:dialpeer, dialpeer_attrs) }
  let(:dialpeer_attrs) do
    {
      prefix: '99912',
      vendor: vendor,
      gateway: gateway,
      routing_tag_ids: [routing_tags.first.id, routing_tags.third.id, nil]
    }
  end

  it 'shows correct details page' do
    subject
    expect(page).to have_attribute_row('PREFIX', exact_text: dialpeer.prefix)
    expect(page).to have_attribute_row('DST NUMBER MIN LENGTH', exact_text: dialpeer.dst_number_min_length.to_s)
    expect(page).to have_attribute_row('DST NUMBER MAX LENGTH', exact_text: dialpeer.dst_number_max_length.to_s)
    expect(page).to have_attribute_row('COUNTRY', exact_text: 'EMPTY')
    expect(page).to have_attribute_row('NETWORK', exact_text: 'EMPTY')
    expect(page).to have_attribute_row('ENABLED', exact_text: 'YES')
    expect(page).to have_attribute_row('LOCKED', exact_text: 'NO')
    expect(page).to have_attribute_row('ROUTING GROUP', exact_text: dialpeer.routing_group.display_name)
    tags_line = "#{routing_tags.first.name.upcase} | #{routing_tags.third.name.upcase} | ANY TAG"
    expect(page).to have_attribute_row('ROUTING TAGS', exact_text: tags_line)
    expect(page).to have_attribute_row('ROUTING TAG MODE', exact_text: 'OR')
    expect(page).to have_attribute_row('VENDOR', exact_text: dialpeer.vendor.display_name)
    expect(page).to have_attribute_row('ACCOUNT', exact_text: dialpeer.account.display_name)
    expect(page).to have_attribute_row('ROUTESET DISCRIMINATOR', exact_text: dialpeer.routeset_discriminator.display_name)
    expect(page).to have_attribute_row('PRIORITY', exact_text: dialpeer.priority.to_s)
    expect(page).to have_attribute_row('FORCE HIT RATE', exact_text: 'EMPTY')
    expect(page).to have_attribute_row('EXCLUSIVE ROUTE', exact_text: 'NO')
    expect(page).to have_attribute_row('INITIAL INTERVAL', exact_text: dialpeer.initial_interval.to_s)
    expect(page).to have_attribute_row('INITIAL RATE', exact_text: dialpeer.initial_rate.to_s)
    expect(page).to have_attribute_row('NEXT INTERVAL', exact_text: dialpeer.next_interval.to_s)
    expect(page).to have_attribute_row('NEXT RATE', exact_text: dialpeer.next_rate.to_s)
    expect(page).to have_attribute_row('LCR RATE MULTIPLIER', exact_text: dialpeer.lcr_rate_multiplier.to_s)
    expect(page).to have_attribute_row('CONNECT FEE', exact_text: dialpeer.connect_fee.to_s)
    expect(page).to have_attribute_row('REVERSE BILLING', exact_text: 'NO')
    expect(page).to have_attribute_row('GATEWAY', exact_text: dialpeer.gateway.display_name)
    expect(page).to have_attribute_row('GATEWAY GROUP', exact_text: 'EMPTY')
    expect(page).to have_attribute_row('VALID FROM', exact_text: dialpeer.valid_from.strftime('%F %T'))
    expect(page).to have_attribute_row('VALID TILL', exact_text: dialpeer.valid_till.strftime('%F %T'))
    expect(page).to have_attribute_row('CAPACITY', exact_text: dialpeer.capacity.to_s)
    expect(page).to have_attribute_row('SRC NAME REWRITE RULE', exact_text: 'EMPTY')
    expect(page).to have_attribute_row('SRC NAME REWRITE RESULT', exact_text: 'EMPTY')
    expect(page).to have_attribute_row('SRC REWRITE RULE', exact_text: 'EMPTY')
    expect(page).to have_attribute_row('SRC REWRITE RESULT', exact_text: 'EMPTY')
    expect(page).to have_attribute_row('DST REWRITE RULE', exact_text: 'EMPTY')
    expect(page).to have_attribute_row('DST REWRITE RESULT', exact_text: 'EMPTY')
    expect(page).to have_attribute_row('ACD LIMIT', exact_text: dialpeer.acd_limit.to_s)
    expect(page).to have_attribute_row('ASR LIMIT', exact_text: dialpeer.asr_limit.to_s)
    expect(page).to have_attribute_row('SHORT CALLS LIMIT', exact_text: dialpeer.short_calls_limit.to_s)
    expect(page).to have_attribute_row('CREATED AT', exact_text: dialpeer.created_at.strftime('%F %T'))
    expect(page).to have_attribute_row('EXTERNAL ID', exact_text: dialpeer.external_id.to_s)
    expect(page).to have_attribute_row('CURRENT RATE ID', exact_text: 'EMPTY')
  end

  context 'when dialpeer not tagged' do
    let(:dialpeer_attrs) do
      super().merge routing_tag_ids: []
    end

    it 'shows correct details page' do
      subject
      expect(page).to have_attribute_row('PREFIX', exact_text: dialpeer.prefix)
      expect(page).to have_attribute_row('ROUTING TAGS', exact_text: 'NOT TAGGED')
    end
  end
end
