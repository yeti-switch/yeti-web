# frozen_string_literal: true

require 'spec_helper'

describe 'Copy Dialpeer', type: :feature do
  include_context :login_as_admin

  let(:record) { create(:dialpeer, attrs) }

  let(:attrs) do
    {
      prefix: '123'
    }
  end

  before do
    visit dialpeer_path(record.id)
    click_link 'Copy'
  end

  it 'check only not standart attribute **batch_prefix**' do
    within 'form#new_dialpeer' do
      expect(page).to have_field('Prefix', with: attrs[:prefix])
    end
  end
end
