# frozen_string_literal: true

RSpec.describe 'Create new Node', type: :feature do
  include_context :login_as_admin

  before do
    @pop = create(:pop)
    visit new_node_path
  end

  include_context :fill_form, 'new_node' do
    let(:attributes) do
      {
        id: 1,
        name: 'test Node',
        pop_id: @pop.name,
        rpc_endpoint: '10.10.10.10:7080'
      }
    end

    it 'creates new Node succesfully' do
      click_on_submit

      expect(page).to have_css('.flash_notice', text: 'Node was successfully created.')

      expect(Node.last).to have_attributes(
        id: attributes[:id],
        name: attributes[:name],
        pop_id: @pop.id,
        rpc_endpoint: attributes[:rpc_endpoint]
      )
    end
  end
end
