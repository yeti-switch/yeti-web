# frozen_string_literal: true

RSpec.describe ActiveAdmin::PerPageExtension do
  # Minimal controller-like harness that includes the concern, so we can drive
  # the clause logic without the full ActiveAdmin/Rails stack.
  let(:controller_class) do
    Class.new do
      def self.before_action(*); end # stub the `included do` hook

      include ActiveAdmin::PerPageExtension
      attr_accessor :params, :current_admin_user
    end
  end

  let(:controller) { controller_class.new }
  let(:stored) { {} }
  let(:admin_user) { instance_double(AdminUser, per_page: stored) }

  before do
    allow(ActiveAdmin.application).to receive(:default_per_page).and_return([30, 50, 100])
    controller.current_admin_user = admin_user
    controller.params = { controller: 'accounts', per_page: nil }.with_indifferent_access
  end

  describe '#dynamic_per_page' do
    context 'with a remembered value for this resource' do
      let(:stored) { { 'accounts' => 50 } }

      it 'returns it' do
        expect(controller.dynamic_per_page).to eq(50)
      end
    end

    it 'falls back to the first option when nothing is stored' do
      expect(controller.dynamic_per_page).to eq(30)
    end

    it 'falls back to the first option when the stored value is no longer an allowed option' do
      stored['accounts'] = 999
      expect(controller.dynamic_per_page).to eq(30)
    end
  end

  describe '#persist_per_page' do
    it 'stores a newly chosen value with a single update_column and no extra SELECT' do
      controller.params[:per_page] = '50'
      expect(AdminUser).not_to receive(:find) # no per-request re-fetch
      expect(admin_user).to receive(:update_column).with(:per_page, { 'accounts' => 50 })
      controller.send(:persist_per_page)
    end

    it 'merges without clobbering other resources' do
      stored['contracts'] = 100
      controller.params[:per_page] = '50'
      expect(admin_user).to receive(:update_column).with(:per_page, { 'contracts' => 100, 'accounts' => 50 })
      controller.send(:persist_per_page)
    end

    it 'does not write when the choice is unchanged' do
      stored['accounts'] = 50
      controller.params[:per_page] = '50'
      expect(admin_user).not_to receive(:update_column)
      controller.send(:persist_per_page)
    end

    it 'does not write when no per_page param is present' do
      expect(admin_user).not_to receive(:update_column)
      controller.send(:persist_per_page)
    end

    it 'coerces an out-of-range choice to the default before storing' do
      controller.params[:per_page] = '999'
      expect(admin_user).to receive(:update_column).with(:per_page, { 'accounts' => 30 })
      controller.send(:persist_per_page)
    end
  end

  # e.g. the admin once chose 100, then admin_ui.per_page was narrowed to [30,50,100]→[30,50].
  context 'when the stored value is no longer allowed by config' do
    let(:stored) { { 'accounts' => 100 } }

    before { allow(ActiveAdmin.application).to receive(:default_per_page).and_return([30, 50]) }

    it 'applies the default instead of the stale value' do
      expect(controller.dynamic_per_page).to eq(30)
    end

    it 'leaves the stale value untouched on a plain visit (no write, lazy heal)' do
      expect(admin_user).not_to receive(:update_column)
      controller.send(:persist_per_page)
      expect(stored).to eq('accounts' => 100)
    end

    it 'overwrites the stale value once the admin picks an allowed size' do
      controller.params[:per_page] = '50'
      expect(admin_user).to receive(:update_column).with(:per_page, { 'accounts' => 50 })
      controller.send(:persist_per_page)
    end
  end
end
