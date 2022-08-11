# frozen_string_literal: true

RSpec.describe 'Edit Dialpeer', js: true do
  subject do
    visit edit_dialpeer_path(record.id)
    fill_form!
    submit_form!
  end

  include_context :login_as_admin
  let(:submit_form!) do
    click_button 'Update Dialpeer'
  end

  let!(:routing_tags) do
    FactoryBot.create_list(:routing_tag, 5)
  end
  let!(:record) do
    FactoryBot.create(:dialpeer)
  end

  context 'when nothing changed' do
    let(:fill_form!) { nil }
    let!(:record) do
      FactoryBot.create(
        :dialpeer,
        routing_tag_ids: [routing_tags[0].id, nil],
        # empty string applied by default when dialpeer created from admin UI
        dst_rewrite_result: '',
        dst_rewrite_rule: '',
        src_name_rewrite_result: '',
        src_name_rewrite_rule: '',
        src_rewrite_result: '',
        src_rewrite_rule: '',
        # timestamps cropped to minutes when dialpeer created from admin UI
        valid_from: 1.day.ago.change(sec: 0),
        valid_till: 1.day.ago.change(sec: 0)
      )
    end

    it 'does not change attributes' do
      expect {
        subject
        expect(page).to have_flash_message('Dialpeer was successfully updated.', type: :notice)
      }.not_to change {
        record.reload.attributes
      }
    end
  end

  context 'with rates change' do
    let(:fill_form!) do
      fill_in 'Initial rate', with: '0.31'
      fill_in 'Next rate', with: '0.72'
    end

    it 'changes rates' do
      subject
      expect(page).to have_flash_message('Dialpeer was successfully updated.', type: :notice)
      expect(record.reload).to have_attributes(
                                 initial_rate: 0.31,
                                 next_rate: 0.72
                               )
    end
  end

  context 'with empty routing tags' do
    let!(:record) do
      FactoryBot.create(:dialpeer, routing_tag_ids: [routing_tags[2].id, nil])
    end
    let(:fill_form!) do
      chosen_deselect_values 'Routing tags', values: [routing_tags[2].name, Routing::RoutingTag::ANY_TAG]
    end

    it 'changes routing tags' do
      subject
      expect(page).to have_flash_message('Dialpeer was successfully updated.', type: :notice)
      expect(record.reload).to have_attributes(
                                 routing_tag_ids: []
                               )
    end
  end

  context 'with filled routing tags' do
    let(:fill_form!) do
      fill_in_chosen 'Routing tags', with: Routing::RoutingTag::ANY_TAG, multiple: true
      fill_in_chosen 'Routing tags', with: routing_tags[3].name, multiple: true
      fill_in_chosen 'Routing tags', with: routing_tags[1].name, multiple: true
      fill_in_chosen 'Routing tags', with: routing_tags[2].name, multiple: true
    end

    it 'changes routing tags' do
      subject
      expect(page).to have_flash_message('Dialpeer was successfully updated.', type: :notice)
      expect(record.reload).to have_attributes(
                                 routing_tag_ids: [
                                   routing_tags[1].id,
                                   routing_tags[2].id,
                                   routing_tags[3].id,
                                   nil
                                 ]
                               )
    end
  end
end
