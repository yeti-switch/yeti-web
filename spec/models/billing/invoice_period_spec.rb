# frozen_string_literal: true

require 'spec_helper'

describe Billing::InvoicePeriod do
  subject do
    Billing::InvoicePeriod.find(id)
  end

  let(:id) { Billing::InvoicePeriod::NAMES.key(name.upcase) }

  shared_examples :should_set_correct_dates do
    let(:dt) { nil }
    let(:expected_next_dt) { nil }
    let(:expected_initial_dt) { nil }
    let(:expected_next_from_now_dt) { expected_next_dt }
    before { allow(Billing::InvoicePeriod).to receive(:today).and_return dt.to_date }
    it 'should return correct next_date' do
      expect(subject.next_date(dt).to_time.to_s(:db)).to eq expected_next_dt.to_time.to_s(:db)
    end
    it 'should return correct next_date_from_now' do
      expect(subject.next_date_from_now.to_time.to_s(:db)).to eq expected_next_from_now_dt.to_time.to_s(:db)
    end
    it 'should return correct initial_date' do
      end_date = Time.now.to_date
      expect(subject.initial_date(end_date).to_time.to_time.to_s(:db)).to eq expected_initial_dt.to_time.to_s(:db)
    end
  end

  context 'WEEKLY' do
    let(:name) { 'weekly' }

    context 'when invoice did not break month' do
      include_examples :should_set_correct_dates do
        let(:dt) { Time.parse('2015-07-06 00:00:00') }
        let(:expected_next_dt) { dt + 1.week }
        let(:expected_initial_dt) { dt.to_time }
      end
    end

    context 'when invoice breaks month' do
      include_examples :should_set_correct_dates do
        let(:dt) { Time.parse('2015-07-27 00:00:00') }
        let(:expected_next_dt) { dt + 1.week }
        let(:expected_initial_dt) { dt.to_time }
      end
    end

    context 'when invoice on last week of the year' do
      include_examples :should_set_correct_dates do
        let(:dt) { Time.parse('2017-12-27 00:00:00') }
        let(:expected_next_dt) { dt + 1.week }
        let(:expected_initial_dt) { dt.beginning_of_week }
        let(:expected_next_from_now_dt) { expected_next_dt.beginning_of_week }
      end
    end
  end # WEEKLY

  context 'WEEKLY_SPLIT' do
    let(:name) { 'weekly_split' }

    context 'when invoice did not break month' do
      include_examples :should_set_correct_dates do
        let(:dt) { Time.parse('2015-07-06 00:00:00') }
        let(:expected_next_dt) { dt.to_time + 1.week }
        let(:expected_initial_dt) { dt.to_time }
      end
    end

    context 'when invoice breaks month' do
      context 'first part' do
        include_examples :should_set_correct_dates do
          let(:dt) { Time.parse('2015-07-27 00:00:00') }
          let(:expected_next_dt) { Time.parse('2015-08-01 00:00:00') }
          let(:expected_initial_dt) { dt.to_time }
        end
      end
      context 'second part' do
        include_examples :should_set_correct_dates do
          let(:dt) { Time.parse('2015-08-01 00:00:00') }
          let(:expected_next_dt) { Time.parse('2015-08-03 00:00:00') }
          let(:expected_initial_dt) { dt.to_time }
        end
      end
    end
  end # WEEKLY_SPLIT

  context 'BIWEEKLY' do
    let(:name) { 'biweekly' }

    context 'even week' do
      context 'when invoice did not break month' do
        include_examples :should_set_correct_dates do
          let(:dt) { Time.parse('2015-07-06 00:00:00') } # week 28
          let(:expected_next_dt) { dt + 2.week }
          let(:expected_initial_dt) { dt }
        end
      end

      context 'when invoice breaks month' do
        context 'when breaks first week' do
          include_examples :should_set_correct_dates do
            let(:dt) { Time.parse('2015-04-27 00:00:00') } # week 18
            let(:expected_next_dt) { dt + 2.week }
            let(:expected_initial_dt) { dt }
          end
        end

        context 'when breaks second week' do
          include_examples :should_set_correct_dates do
            let(:dt) { Time.parse('2015-06-22 00:00:00') } # week 26
            let(:expected_next_dt) { dt + 2.week }
            let(:expected_initial_dt) { dt }
          end
        end
      end
    end # even week

    context 'odd week' do
      context 'when invoice did not break month' do
        include_examples :should_set_correct_dates do
          let(:dt) { Time.parse('2015-07-13 00:00:00') } # week 29
          let(:expected_next_dt) { dt + 2.week }
          let(:expected_next_from_now_dt) { dt + 1.week }
          let(:expected_initial_dt) { dt - 1.week }
        end
      end

      context 'when invoice breaks month' do
        context 'when breaks first week' do
          include_examples :should_set_correct_dates do
            let(:dt) { Time.parse('2015-06-29 00:00:00') } # week 27
            let(:expected_next_dt) { dt + 2.week }
            let(:expected_next_from_now_dt) { dt + 1.week }
            let(:expected_initial_dt) { dt - 1.week }
          end
        end

        context 'whn breaks second week' do
          include_examples :should_set_correct_dates do
            let(:dt) { Time.parse('2015-04-20 00:00:00') } # week 17
            let(:expected_next_dt) { dt + 2.week }
            let(:expected_next_from_now_dt) { dt + 1.week }
            let(:expected_initial_dt) { dt - 1.week }
          end
        end
      end
    end # odd week
  end # BIWEEKLY

  context 'BIWEEKLY_SPLIT' do
    let(:name) { 'biweekly_split' }

    context 'even week' do
      context 'when invoice did not break month' do
        include_examples :should_set_correct_dates do
          let(:dt) { Time.parse('2015-07-06 00:00:00') } # week 28
          let(:expected_next_dt) { dt + 2.week }
          let(:expected_initial_dt) { dt }
        end
      end

      context 'when invoice breaks month' do
        context 'when breaks first week' do
          context 'first part' do
            include_examples :should_set_correct_dates do
              let(:dt) { Time.parse('2015-04-27 00:00:00') } # week 18
              let(:expected_next_dt) { Time.parse('2015-05-01 00:00:00') } # week 18
              let(:expected_initial_dt) { dt }
            end
          end

          context 'second part' do
            include_examples :should_set_correct_dates do
              let(:dt) { Time.parse('2015-05-01 00:00:00') } # week 18
              let(:expected_next_dt) { Time.parse('2015-05-11 00:00:00') } # week 20
              let(:expected_initial_dt) { dt }
            end
          end
        end

        context 'when breaks second week' do
          context 'second part' do
            include_examples :should_set_correct_dates do
              let(:dt) { Time.parse('2015-06-22 00:00:00') } # week 26
              let(:expected_next_dt) { Time.parse('2015-07-01 00:00:00') } # week 27
              let(:expected_initial_dt) { dt }
            end
          end

          context 'second part' do
            include_examples :should_set_correct_dates do
              let(:dt) { Time.parse('2015-07-01 00:00:00') } # week 27
              let(:expected_next_dt) { Time.parse('2015-07-06 00:00:00') } # week 28
              let(:expected_initial_dt) { dt }
            end
          end
        end
      end
    end # even week

    context 'odd week' do
      context 'when invoice did not break month' do
        include_examples :should_set_correct_dates do
          let(:dt) { Time.parse('2015-07-13 00:00:00') } # week 29
          # cause it will move to the even week
          let(:expected_next_dt) { dt + 1.week }
          let(:expected_initial_dt) { dt - 1.week }
        end
      end

      context 'when invoice breaks month' do
        context 'when breaks first week' do
          context 'first part' do
            include_examples :should_set_correct_dates do
              let(:dt) { Time.parse('2015-06-29 00:00:00') } # week 27
              let(:expected_next_dt) { Time.parse('2015-07-01 00:00:00') } # week 27
              # cause it will move to the even week
              let(:expected_initial_dt) { Time.parse('2015-06-22 00:00:00') } # week 26
            end
          end

          context 'second part' do
            include_examples :should_set_correct_dates do
              let(:dt) { Time.parse('2015-07-01 00:00:00') } # week 27
              # cause it will move to the even week
              let(:expected_next_dt) { Time.parse('2015-07-06 00:00:00') } # week 28
              let(:expected_initial_dt) { dt }
            end
          end
        end

        context 'when breaks second week' do
          context 'first part' do
            include_examples :should_set_correct_dates do
              let(:dt) { Time.parse('2015-04-20 00:00:00') } # week 17
              # cause it will move to the even week
              let(:expected_next_dt) { Time.parse('2015-04-27 00:00:00') } # week 18
              let(:expected_initial_dt) { Time.parse('2015-04-13 00:00:00') } # week 18
            end
          end
        end
      end
    end # odd week
  end # BIWEEKLY_SPLIT
end
