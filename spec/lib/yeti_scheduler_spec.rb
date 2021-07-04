# frozen_string_literal: true

require 'yeti_scheduler'

RSpec.describe YetiScheduler do
  describe '.start!' do
    subject do
      described_class.start!(*args)
    end

    let(:args) { [wait: true] }

    let(:scheduler_stub) { instance_double(described_class) }

    context 'when scheduler not started' do
      before do
        expect(described_class).to receive(:scheduler).once.ordered.and_return(nil)
      end

      it 'runs described_class instance' do
        expect(described_class).to receive(:new).with(*args).once.ordered.and_return(scheduler_stub)
        expect(described_class).to receive(:scheduler=).once.ordered.with(scheduler_stub)
        expect(described_class).to receive(:scheduler).once.ordered.and_return(scheduler_stub)
        expect(scheduler_stub).to receive(:run!).once.ordered
        subject
      end
    end

    context 'when scheduler already started' do
      before do
        expect(described_class).to receive(:scheduler).twice.and_return(scheduler_stub)
        expect(scheduler_stub).to receive(:running?).once.and_return(true)
      end

      it 'raises ArgumentError' do
        expect(described_class).to_not receive(:new)
        expect(described_class).to_not receive(:scheduler=)
        expect { subject }.to raise_error(ArgumentError, 'scheduler already started')
      end
    end
  end

  describe '#run!' do
    subject do
      described_instance.run!
    end

    let!(:described_instance) { described_class.new(*args) }

    let(:rufus_stub) { instance_double(Rufus::Scheduler) }
    before do
      expect(Yeti::ActiveRecord).to receive(:clear_active_connections!).once
      expect(Yeti::ActiveRecord).to receive(:flush_idle_connections!).once
      expect(Cdr::Base).to receive(:clear_active_connections!).once
      expect(Cdr::Base).to receive(:flush_idle_connections!).once

      expect(Rufus::Scheduler).to receive(:new).and_return(rufus_stub)
      described_class._cron_handlers.each do |handler_class|
        job_double = double
        time_double = double
        expect(rufus_stub).to receive(:cron)
          .with(handler_class.cron_line, handler_class.scheduler_options)
          .and_yield(job_double, time_double)

        # called when cron time is come but we yield it in test stub above to check #run_handler being run
        expect(described_instance).to receive(:run_handler)
          .with(handler_class, job_double, time_double)
          .once
      end
    end

    context 'with wait: true' do
      let(:args) { [wait: true] }

      it 'starts Rufus::Scheduler in blocking mode' do
        expect(rufus_stub).to receive(:join).once
        subject
      end
    end

    context 'with wait: false' do
      let(:args) { [wait: false] }

      it 'starts Rufus::Scheduler in non-blocking mode' do
        expect(rufus_stub).to_not receive(:join)
        subject
      end
    end
  end

  describe '#run_handler' do
    subject do
      described_instance.run_handler(handler_class, job_double, time_double)
    end

    let!(:described_instance) { described_class.new(wait: true) }
    let(:scheduler_options) { handler_class.scheduler_options }
    let!(:job_double) { instance_double(Rufus::Scheduler::CronJob, name: handler_name) }
    let!(:time_double) { instance_double(EtOrbi::EoTime) }

    before do
      expect(Yeti::ActiveRecord.connection_pool).to receive(:connection).once.ordered
      expect(Cdr::Base.connection_pool).to receive(:connection).once.ordered

      # We stubbing active record model because we required to stub connection_pool connect/release.
      # Without such stubs tests wil break.
      job_info_class = double
      stub_const('CronJobInfo', job_info_class)
      expect(job_info_class).to receive(:find_by!).with(name: handler_name).once.and_return(job_info_stub)
    end
    let(:job_info_stub) { double }
    let(:matcher_options_before) do
      satisfy do |options|
        expect(options).to be_a_kind_of(Scheduler::Base::RunOptions)
        expect(options.name).to eq(handler_name)
        expect(options.handler_class).to eq(handler_class)
        expect(options.job).to eq(job_double)
        expect(options.time).to eq(time_double)
        expect(options.started_at).to be_within(1).of(Time.zone.now)
        expect(options.ended_at).to be_nil
        expect(options.duration).to be_nil
        expect(options.success).to be_nil
        expect(options.exception).to be_nil
      end
    end

    shared_examples :runs_successfully do
      it 'runs successfully' do
        expect(CaptureError).to_not receive(:capture)
        subject
      end
    end

    shared_examples :runs_with_captured_exception do
      it 'runs with captured exception' do
        expect(CaptureError).to receive(:capture).with(
          raised_exception, capture_payload
        ).once.ordered
        subject
      end
    end

    YetiScheduler._cron_handlers.each do |handler|
      context "with handler_class #{handler}" do
        let!(:handler_class) { handler }
        let(:handler_name) { scheduler_options[:name] }

        context 'when handler executes successfully' do
          let(:matcher_options_after) do
            satisfy do |options|
              expect(options).to be_a_kind_of(Scheduler::Base::RunOptions)
              expect(options.name).to eq(handler_name)
              expect(options.handler_class).to eq(handler_class)
              expect(options.job).to eq(job_double)
              expect(options.time).to eq(time_double)
              expect(options.started_at).to be_within(1).of(Time.zone.now)
              expect(options.ended_at).to be_within(1).of(Time.zone.now)
              expect(options.duration).to be > 0
              expect(options.success).to eq(true)
              expect(options.exception).to be_nil
            end
          end
          let(:test_middleware) do
            Class.new(Scheduler::Middleware::Base) do
              def call(options)
                app.call(options)
                self.class.check!(options)
              end
            end
          end

          before do
            YetiScheduler.use(test_middleware)
            expect(handler_class).to receive(:call).with(matcher_options_before).once.ordered
            expect(test_middleware).to receive(:check!).with(matcher_options_after).once.ordered
            expect(Yeti::ActiveRecord.connection_pool).to receive(:release_connection).once.ordered
            expect(Cdr::Base.connection_pool).to receive(:release_connection).once.ordered

            expect(job_info_stub).to receive(:update!).with(
              last_run_at: be_within(1).of(Time.zone.now),
              last_duration: be > 0,
              last_exception: nil
            ).once
          end

          after do
            YetiScheduler._middlewares.pop
          end

          context 'with disabled prometheus' do
            before do
              allow(PrometheusConfig).to receive(:enabled?).and_return(false)
              expect(YetiCronJobProcessor).to_not receive(:collect)
            end

            include_examples :runs_successfully
          end

          context 'with enabled prometheus' do
            before do
              allow(PrometheusConfig).to receive(:enabled?).and_return(true)
              expect(YetiCronJobProcessor).to receive(:collect).with(
                name: handler_name,
                success: true,
                duration: be > 0
              ).once
            end

            include_examples :runs_successfully
          end
        end

        context 'when handler executes with exception' do
          let(:raised_exception) { StandardError.new('test') }
          let(:capture_payload) do
            {
              tags: { component: described_class.name, job_name: handler_name },
              extra: {
                options: {
                  name: handler_name,
                  handler_class: handler_class,
                  job: job_double,
                  time: time_double,
                  started_at: be_within(1).of(Time.zone.now),
                  ended_at: be_within(1).of(Time.zone.now),
                  duration: be > 0,
                  success: false,
                  exception: raised_exception
                },
                scheduler_options: scheduler_options
              }
            }
          end
          before do
            expect(handler_class).to receive(:call).with(matcher_options_before).once.ordered.and_raise(raised_exception)
            expect(Yeti::ActiveRecord.connection_pool).to receive(:release_connection).once.ordered
            expect(Cdr::Base.connection_pool).to receive(:release_connection).once.ordered

            expect(job_info_stub).to receive(:update!).with(
              last_run_at: be_within(1).of(Time.zone.now),
              last_duration: be > 0,
              last_exception: be_present
            ).once
          end

          context 'with disabled prometheus' do
            before do
              allow(PrometheusConfig).to receive(:enabled?).and_return(false)
              expect(YetiCronJobProcessor).to_not receive(:collect)
            end

            include_examples :runs_with_captured_exception
          end

          context 'with enabled prometheus' do
            before do
              allow(PrometheusConfig).to receive(:enabled?).and_return(true)
              expect(YetiCronJobProcessor).to receive(:collect).with(
                name: handler_name,
                success: false,
                duration: be > 0
              ).once
            end

            include_examples :runs_with_captured_exception
          end
        end
      end
    end
  end
end
