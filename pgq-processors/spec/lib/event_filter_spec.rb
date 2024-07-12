# frozen_string_literal: true

require File.join(__dir__, '../../lib/event_filter')

RSpec.describe EventFilter do
  describe '#match?' do
    subject do
      event_filter.match?(event)
    end

    let(:event_filter) { described_class.new(**filter_options) }
    let(:filter_options) { { field: 'some', op: operator, value: } }

    context 'when operator is eq' do
      let(:operator) { 'eq' }
      let(:value) { 'test' }

      context 'with event.some is equal to value' do
        let(:event) do
          { 'some' => 'test' }
        end

        it { is_expected.to eq(true) }

        context 'when value is string but event.some is integer' do
          let(:value) { '1' }
          let(:event) do
            { 'some' => 1 }
          end

          it { is_expected.to eq(false) }
        end

        context 'when value is integer but event.some is string' do
          let(:value) { '1' }
          let(:event) do
            { 'some' => 1 }
          end

          it { is_expected.to eq(false) }
        end
      end

      context 'with event.some is not equal to value' do
        let(:event) do
          { 'some' => 'not_test' }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some is nil' do
        let(:event) do
          { 'some' => nil }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(false) }
      end
    end

    context 'when operator is not_eq' do
      let(:operator) { 'not_eq' }
      let(:value) { 'test' }

      context 'with event.some is equal to value' do
        let(:event) do
          { 'some' => 'test' }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some is not equal to value' do
        let(:event) do
          { 'some' => 'not_test' }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some is nil' do
        let(:event) do
          { 'some' => nil }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(true) }
      end
    end

    context 'when operator is start_with' do
      let(:operator) { 'start_with' }
      let(:value) { 'te' }

      context 'with event.some start with value' do
        let(:event) do
          { 'some' => 'test' }
        end

        it { is_expected.to eq(true) }

        context 'when value is integer and event.some is integer' do
          let(:value) { 123 }
          let(:event) do
            { 'some' => 12_345 }
          end

          it { is_expected.to eq(true) }
        end

        context 'when value is string but event.some is integer' do
          let(:value) { '123' }
          let(:event) do
            { 'some' => 12_345 }
          end

          it { is_expected.to eq(true) }
        end

        context 'when value is integer but event.some is string' do
          let(:value) { 123 }
          let(:event) do
            { 'some' => '12345' }
          end

          it { is_expected.to eq(true) }
        end
      end

      context 'with event.some not start with value' do
        let(:event) do
          { 'some' => 'este' }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some is nil' do
        let(:event) do
          { 'some' => nil }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(false) }
      end
    end

    context 'when operator is end_with' do
      let(:operator) { 'end_with' }
      let(:value) { 'st' }

      context 'with event.some end with value' do
        let(:event) do
          { 'some' => 'test' }
        end

        it { is_expected.to eq(true) }

        context 'when value is integer and event.some is integer' do
          let(:value) { 45 }
          let(:event) do
            { 'some' => 12_345 }
          end

          it { is_expected.to eq(true) }
        end

        context 'when value is string but event.some is integer' do
          let(:value) { '45' }
          let(:event) do
            { 'some' => 12_345 }
          end

          it { is_expected.to eq(true) }
        end

        context 'when value is integer but event.some is string' do
          let(:value) { 45 }
          let(:event) do
            { 'some' => '12345' }
          end

          it { is_expected.to eq(true) }
        end
      end

      context 'with event.some not end with value' do
        let(:event) do
          { 'some' => 'stet' }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some is nil' do
        let(:event) do
          { 'some' => nil }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(false) }
      end
    end

    context 'when operator is contains' do
      let(:operator) { 'contains' }
      let(:value) { 'es' }

      context 'with event.some contains value' do
        let(:event) do
          { 'some' => 'test' }
        end

        it { is_expected.to eq(true) }

        context 'when value is integer and event.some is integer' do
          let(:value) { 34 }
          let(:event) do
            { 'some' => 12_345 }
          end

          it { is_expected.to eq(true) }
        end

        context 'when value is string but event.some is integer' do
          let(:value) { '34' }
          let(:event) do
            { 'some' => 12_345 }
          end

          it { is_expected.to eq(true) }
        end

        context 'when value is integer but event.some is string' do
          let(:value) { 34 }
          let(:event) do
            { 'some' => '12345' }
          end

          it { is_expected.to eq(true) }
        end
      end

      context 'with event.some not contains value' do
        let(:event) do
          { 'some' => 'tiset' }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some is nil' do
        let(:event) do
          { 'some' => nil }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(false) }
      end
    end

    context 'when operator is gt' do
      let(:operator) { 'gt' }
      let(:value) { 10 }

      context 'with event.some greater than value' do
        let(:event) do
          { 'some' => 11 }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some less than value' do
        let(:event) do
          { 'some' => 9 }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some equal to value' do
        let(:event) do
          { 'some' => 10 }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some is nil' do
        let(:event) do
          { 'some' => nil }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(false) }
      end
    end

    context 'when operator is lt' do
      let(:operator) { 'lt' }
      let(:value) { 10 }

      context 'with event.some less than value' do
        let(:event) do
          { 'some' => 9 }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some greater than value' do
        let(:event) do
          { 'some' => 11 }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some equal to value' do
        let(:event) do
          { 'some' => 10 }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some is nil' do
        let(:event) do
          { 'some' => nil }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(false) }
      end
    end

    context 'when operator is gte' do
      let(:operator) { 'gte' }
      let(:value) { 10 }

      context 'with event.some greater than value' do
        let(:event) do
          { 'some' => 11 }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some equal to value' do
        let(:event) do
          { 'some' => 10 }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some less than value' do
        let(:event) do
          { 'some' => 9 }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some is nil' do
        let(:event) do
          { 'some' => nil }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(false) }
      end
    end

    context 'when operator is lte' do
      let(:operator) { 'lte' }
      let(:value) { 10 }

      context 'with event.some less than value' do
        let(:event) do
          { 'some' => 9 }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some equal to value' do
        let(:event) do
          { 'some' => 10 }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some greater than value' do
        let(:event) do
          { 'some' => 11 }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some is nil' do
        let(:event) do
          { 'some' => nil }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(false) }
      end
    end

    context 'when operator is in' do
      let(:operator) { 'in' }
      let(:value) { %w[test test2] }

      context 'with event.some in value' do
        let(:event) do
          { 'some' => 'test' }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some not in value' do
        let(:event) do
          { 'some' => 'not_test' }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some is nil' do
        let(:event) do
          { 'some' => nil }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(false) }
      end
    end

    context 'when operator is not_in' do
      let(:operator) { 'not_in' }
      let(:value) { %w[test test2] }

      context 'with event.some not in value' do
        let(:event) do
          { 'some' => 'not_test' }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some in value' do
        let(:event) do
          { 'some' => 'test' }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some is nil' do
        let(:event) do
          { 'some' => nil }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(true) }
      end
    end

    context 'when operator is null' do
      let(:operator) { 'null' }
      let(:value) { nil }

      context 'with event.some is null' do
        let(:event) do
          { 'some' => nil }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some is not null' do
        let(:event) do
          { 'some' => 'test' }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(true) }
      end
    end

    context 'when operator is not_null' do
      let(:operator) { 'not_null' }
      let(:value) { nil }

      context 'with event.some is null' do
        let(:event) do
          { 'some' => nil }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some is not null' do
        let(:event) do
          { 'some' => 'test' }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(false) }
      end
    end

    context 'when operator is true' do
      let(:operator) { 'true' }
      let(:value) { true }

      context 'with event.some is true' do
        let(:event) do
          { 'some' => true }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some is false' do
        let(:event) do
          { 'some' => false }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(false) }
      end
    end

    context 'when operator is false' do
      let(:operator) { 'false' }
      let(:value) { false }

      context 'with event.some is false' do
        let(:event) do
          { 'some' => false }
        end

        it { is_expected.to eq(true) }
      end

      context 'with event.some is true' do
        let(:event) do
          { 'some' => true }
        end

        it { is_expected.to eq(false) }
      end

      context 'with event.some key not exist' do
        let(:event) { {} }

        it { is_expected.to eq(false) }
      end
    end
  end
end
