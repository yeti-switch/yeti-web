# frozen_string_literal: true

namespace :db do
  namespace :second_base do
    desc 'Alias for db:second_base:drop:_unsafe'
    task drop: :environment do
      SecondBase.on_base { Rake::Task['db:drop:_unsafe'].execute }
    end
  end
end
