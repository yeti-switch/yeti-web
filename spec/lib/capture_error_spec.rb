# frozen_string_literal: true

RSpec.describe CaptureError do
  describe '.rake_task_invocation?' do
    subject { described_class.rake_task_invocation? }

    context 'when Rake is not loaded' do
      before { hide_const('Rake') }

      it { is_expected.to be false }
    end

    context 'when Rake is loaded but no top-level tasks (puma, scheduler, console)' do
      before do
        allow(Rake.application).to receive(:top_level_tasks).and_return([])
      end

      it { is_expected.to be false }
    end

    context 'when Rake is executing a top-level task' do
      before do
        allow(Rake.application).to receive(:top_level_tasks).and_return(['db:migrate'])
      end

      it { is_expected.to be true }
    end
  end

  describe '#build_before_send (private)' do
    subject(:before_send) { described_class.send(:build_before_send) }

    let(:configuration) do
      config = Sentry::Configuration.new
      config.dsn = 'http://public@example.invalid/1'
      config
    end
    let(:event) { Sentry::ErrorEvent.new(configuration: configuration) }

    before do
      allow(Rails.application.config).to receive(:filter_parameters).and_return([:password])
    end

    it 'should return the same Sentry::ErrorEvent object (not a Hash)' do
      result = before_send.call(event)
      expect(result).to be(event)
      expect(result).to be_a(Sentry::ErrorEvent)
    end

    it 'should mask filter_parameters keys in event.extra and keep other keys' do
      event.extra = { password: 'secret', visible: 'ok' }
      result = before_send.call(event)
      expect(result.extra).to eq(password: '[FILTERED]', visible: 'ok')
    end

    it 'should mask Authorization in event.tags' do
      event.tags = { 'Authorization' => 'Bearer abc', 'probe' => 'on' }
      result = before_send.call(event)
      expect(result.tags).to eq('Authorization' => '[FILTERED]', 'probe' => 'on')
    end

    it 'should mask filter_parameters keys in event.user and event.contexts' do
      event.user = { id: 1, password: 'pw' }
      event.contexts = { extra_ctx: { password: 'pw2', note: 'visible' } }
      result = before_send.call(event)
      expect(result.user).to eq(id: 1, password: '[FILTERED]')
      expect(result.contexts).to eq(extra_ctx: { password: '[FILTERED]', note: 'visible' })
    end

    it 'should mask filter_parameters keys and Authorization in event.request fields' do
      request = Sentry::RequestInterface.allocate
      request.data = { password: 'pw', visible: 'ok' }
      request.headers = { 'Authorization' => 'Bearer xyz', 'X-Trace' => 't1' }
      request.env = { 'HTTP_AUTHORIZATION' => 'Bearer xyz', 'REMOTE_ADDR' => '127.0.0.1' }
      event.instance_variable_set(:@request, request)

      result = before_send.call(event)
      expect(result.request.data).to eq(password: '[FILTERED]', visible: 'ok')
      expect(result.request.headers).to eq('Authorization' => '[FILTERED]', 'X-Trace' => 't1')
      expect(result.request.env).to eq('HTTP_AUTHORIZATION' => '[FILTERED]', 'REMOTE_ADDR' => '127.0.0.1')
    end

    it 'should not raise when event.request is nil' do
      event.extra = { password: 'pw' }
      expect { before_send.call(event) }.not_to raise_error
    end

    it 'should not raise when event fields are nil' do
      event.extra = nil
      event.tags = nil
      event.user = nil
      event.contexts = nil
      expect { before_send.call(event) }.not_to raise_error
    end
  end

  describe '.with_clean_context' do
    subject do
      described_class.with_clean_context(context) { block_result }
    end

    let(:context) { { tags: { component: 'test' }, extra: { foo: 'bar' } } }
    let(:block_result) { :ok }

    context 'when sentry disabled' do
      before do
        allow(described_class).to receive(:enabled?).and_return(false)
      end

      it 'yields and returns block result' do
        expect(Sentry).not_to receive(:clone_hub_to_current_thread)
        expect(subject).to eq(:ok)
      end
    end

    context 'when sentry enabled' do
      before do
        allow(described_class).to receive(:enabled?).and_return(true)
        allow(Sentry).to receive(:clone_hub_to_current_thread)
      end

      context 'when Sentry.with_scope yields a scope' do
        let(:scope) { instance_double(Sentry::Scope) }

        before do
          allow(Sentry).to receive(:with_scope).and_yield(scope)
          allow(scope).to receive(:clear_breadcrumbs)
          allow(scope).to receive(:set_tags)
          allow(scope).to receive(:set_extras)
        end

        it 'clears breadcrumbs and yields block result' do
          expect(scope).to receive(:clear_breadcrumbs).once
          expect(subject).to eq(:ok)
        end

        it 'clones hub to current thread' do
          expect(Sentry).to receive(:clone_hub_to_current_thread).once
          subject
        end
      end

      context 'when Sentry.with_scope yields nil scope' do
        before do
          allow(Sentry).to receive(:with_scope).and_yield(nil)
        end

        it 'does not raise and yields block result' do
          expect { subject }.not_to raise_error
          expect(subject).to eq(:ok)
        end
      end
    end
  end
end
