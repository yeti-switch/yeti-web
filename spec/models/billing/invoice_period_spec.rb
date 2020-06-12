# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_periods
#
#  id   :integer          not null, primary key
#  name :string           not null
#

RSpec.describe Billing::InvoicePeriod do
  subject do
    Billing::InvoicePeriod.find(id)
  end

  let(:id) { Billing::InvoicePeriod::NAMES.key(name.upcase) }

  shared_examples :responds_with_correct_times do |today_dt:, next_dt:, initial_dt:, next_from_now_dt: nil|
    next_from_now_dt ||= next_dt

    context "today is #{today_dt.to_date}" do
      it "#next_date for today equals '#{next_dt}'" do
        result = travel_to(today_dt) { subject.next_date(today_dt) }
        expect(result.to_time.to_s(:db)).to eq next_dt.to_time.to_s(:db)
      end

      it "#next_date_from_now equals '#{next_from_now_dt}'" do
        result = travel_to(today_dt) { subject.next_date_from_now }
        expect(result.to_time.to_s(:db)).to eq next_from_now_dt.to_time.to_s(:db)
      end

      it "#initial_date equals '#{initial_dt}'" do
        result = travel_to(today_dt) { subject.initial_date(Time.now.to_date) }
        expect(result.to_time.to_s(:db)).to eq initial_dt.to_time.to_s(:db)
      end
    end
  end

  context 'WEEKLY' do
    let(:name) { 'weekly' }

    context 'when invoice did not break month' do
      include_examples :responds_with_correct_times,
                       today_dt: Time.parse('2015-07-06 00:00:00'),
                       next_dt: Time.parse('2015-07-13 00:00:00'),
                       # start of previous week
                       initial_dt: Time.parse('2015-06-29 00:00:00')
    end

    context 'when invoice breaks month' do
      include_examples :responds_with_correct_times,
                       today_dt: Time.parse('2015-07-27 00:00:00'),
                       next_dt: Time.parse('2015-08-03 00:00:00'),
                       # start of previous week
                       initial_dt: Time.parse('2015-07-20 00:00:00')
    end

    context 'when invoice on last week of the year' do
      include_examples :responds_with_correct_times,
                       today_dt: Time.parse('2017-12-27 00:00:00'),
                       next_dt: Time.parse('2018-01-03 00:00:00'),
                       next_from_now_dt: Time.parse('2018-01-01 00:00:00'),
                       # start of previous week
                       initial_dt: Time.parse('2017-12-18 00:00:00')
    end
  end # WEEKLY

  context 'WEEKLY_SPLIT' do
    let(:name) { 'weekly_split' }

    context 'when invoice did not break month' do
      include_examples :responds_with_correct_times,
                       today_dt: Time.parse('2015-07-06 00:00:00'),
                       next_dt: Time.parse('2015-07-13 00:00:00'),
                       # begin of month
                       initial_dt: Time.parse('2015-07-01 00:00:00')
    end

    context 'when invoice breaks month' do
      context 'first part' do
        include_examples :responds_with_correct_times,
                         today_dt: Time.parse('2015-07-27 00:00:00'),
                         next_dt: Time.parse('2015-08-01 00:00:00'),
                         # start of previous week
                         initial_dt: Time.parse('2015-07-20 00:00:00')
      end

      context 'second part' do
        include_examples :responds_with_correct_times,
                         today_dt: Time.parse('2015-08-01 00:00:00'),
                         next_dt: Time.parse('2015-08-03 00:00:00'),
                         # start_date of first part period
                         initial_dt: Time.parse('2015-07-27 00:00:00')
      end
    end
  end # WEEKLY_SPLIT

  context 'BIWEEKLY' do
    let(:name) { 'biweekly' }

    context 'even week' do
      context 'when invoice did not break month' do
        include_examples :responds_with_correct_times,
                         today_dt: Time.parse('2015-07-06 00:00:00'), # week 28
                         next_dt: Time.parse('2015-07-20 00:00:00'),
                         initial_dt: Time.parse('2015-06-22 00:00:00')
      end

      context 'when invoice breaks month' do
        context 'when breaks first week' do
          include_examples :responds_with_correct_times,
                           today_dt: Time.parse('2015-04-27 00:00:00'), # week 18
                           next_dt: Time.parse('2015-05-11 00:00:00'),
                           initial_dt: Time.parse('2015-04-13 00:00:00')
        end

        context 'when breaks second week' do
          include_examples :responds_with_correct_times,
                           today_dt: Time.parse('2015-06-22 00:00:00'), # week 26
                           next_dt: Time.parse('2015-07-06 00:00:00'),
                           initial_dt: Time.parse('2015-06-08 00:00:00')
        end
      end
    end # even week

    context 'odd week' do
      context 'when invoice did not break month' do
        include_examples :responds_with_correct_times,
                         today_dt: Time.parse('2015-07-13 00:00:00'), # week 29
                         next_dt: Time.parse('2015-07-27 00:00:00'),
                         initial_dt: Time.parse('2015-06-29 00:00:00'),
                         next_from_now_dt: Time.parse('2015-07-20 00:00:00')
      end

      context 'when invoice breaks month' do
        context 'when breaks first week' do
          include_examples :responds_with_correct_times,
                           today_dt: Time.parse('2015-06-29 00:00:00'), # week 27
                           next_dt: Time.parse('2015-07-13 00:00:00'),
                           initial_dt: Time.parse('2015-06-15 00:00:00'),
                           next_from_now_dt: Time.parse('2015-07-06 00:00:00')
        end

        context 'whn breaks second week' do
          include_examples :responds_with_correct_times,
                           today_dt: Time.parse('2015-04-20 00:00:00'), # week 17
                           next_dt: Time.parse('2015-05-04 00:00:00'),
                           initial_dt: Time.parse('2015-04-06 00:00:00'),
                           next_from_now_dt: Time.parse('2015-04-27 00:00:00')
        end
      end
    end # odd week
  end # BIWEEKLY

  context 'BIWEEKLY_SPLIT' do
    let(:name) { 'biweekly_split' }

    context 'even week' do
      context 'when invoice did not break month' do
        include_examples :responds_with_correct_times,
                         today_dt: Time.parse('2015-07-06 00:00:00'), # week 28
                         next_dt: Time.parse('2015-07-20 00:00:00'),
                         initial_dt: Time.parse('2015-07-01 00:00:00')
      end

      context 'when invoice breaks month' do
        context 'when breaks first week' do
          context 'first part' do
            include_examples :responds_with_correct_times,
                             today_dt: Time.parse('2015-04-27 00:00:00'), # week 18
                             next_dt: Time.parse('2015-05-01 00:00:00'), # week 18
                             initial_dt: Time.parse('2015-04-13 00:00:00')
          end

          context 'second part' do
            include_examples :responds_with_correct_times,
                             today_dt: Time.parse('2015-05-01 00:00:00'), # week 18
                             next_dt: Time.parse('2015-05-11 00:00:00'), # week 20
                             initial_dt: Time.parse('2015-04-27 00:00:00')
          end
        end

        context 'when breaks second week' do
          context 'first part' do
            include_examples :responds_with_correct_times,
                             today_dt: Time.parse('2015-06-22 00:00:00'), # week 26
                             next_dt: Time.parse('2015-07-01 00:00:00'), # week 27
                             initial_dt: Time.parse('2015-06-08 00:00:00')
          end

          context 'second part' do
            include_examples :responds_with_correct_times,
                             today_dt: Time.parse('2015-07-01 00:00:00'), # week 27
                             next_dt: Time.parse('2015-07-06 00:00:00'), # week 28
                             initial_dt: Time.parse('2015-06-22 00:00:00')
          end
        end
      end
    end # even week

    context 'odd week' do
      context 'when invoice did not break month' do
        include_examples :responds_with_correct_times,
                         today_dt: Time.parse('2015-07-13 00:00:00'), # week 29
                         # cause it will move to the even week
                         next_dt: Time.parse('2015-07-20 00:00:00'),
                         initial_dt: Time.parse('2015-07-06 00:00:00')
      end

      context 'when invoice breaks month' do
        context 'when breaks first week' do
          context 'first part' do
            include_examples :responds_with_correct_times,
                             today_dt: Time.parse('2015-06-29 00:00:00'), # week 27
                             next_dt: Time.parse('2015-07-01 00:00:00'), # week 27
                             # cause it will move to the even week
                             initial_dt: Time.parse('2015-07-01 00:00:00') # week 26
          end

          context 'second part' do
            include_examples :responds_with_correct_times,
                             today_dt: Time.parse('2015-07-01 00:00:00'), # week 27
                             # cause it will move to the even week
                             next_dt: Time.parse('2015-07-06 00:00:00'), # week 28
                             initial_dt: Time.parse('2015-06-22 00:00:00')
          end
        end

        context 'when breaks second week' do
          context 'first part' do
            include_examples :responds_with_correct_times,
                             today_dt: Time.parse('2015-04-20 00:00:00'), # week 17
                             # cause it will move to the even week
                             next_dt: Time.parse('2015-04-27 00:00:00'), # week 18
                             initial_dt: Time.parse('2015-04-13 00:00:00') # week 18
          end
        end
      end
    end # odd week
  end # BIWEEKLY_SPLIT
end
