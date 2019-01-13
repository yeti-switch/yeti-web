# frozen_string_literal: true

require 'spec_helper'

describe 'Export Routeset discriminator' do
  include_context :login_as_admin

  before { create(:routeset_discriminator) }

  let!(:item) do
    create(:routeset_discriminator)
  end

  before do
    visit routing_routeset_discriminators_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id', item.id.to_s],
        ['Name', item.name]
      ]
    )
  end
end
