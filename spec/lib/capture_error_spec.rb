# frozen_string_literal: true

RSpec.describe CaptureError do
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
