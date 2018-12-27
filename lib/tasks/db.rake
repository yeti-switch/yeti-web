namespace :db do
  namespace :second_base do
    task drop: %i[environment load_config] do
      SecondBase.on_base { Rake::Task['db:drop:_unsafe'].execute }
    end
  end

  # Example for test environment
  # ```
  # RAILS_ENV=test bundle exec rake db:recreate
  # ```
  desc "Destroy and create all databases. Then run pending migrations and seed data."
  task recreate: %i[environment load_config] do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:structure:load'].invoke

    Rake::Task['db:second_base:drop'].invoke
    Rake::Task['db:second_base:create'].invoke
    Rake::Task['db:second_base:structure:load'].invoke

    Rake::Task['db:migrate'].invoke
    Rake::Task['db:second_base:migrate'].invoke

    Rake::Task['db:seed'].invoke
  end
end
