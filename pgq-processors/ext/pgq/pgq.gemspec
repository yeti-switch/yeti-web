# frozen_string_literal: true

require File.dirname(__FILE__) + '/lib/pgq/version'

Gem::Specification.new do |s|
  s.name = 'pgq'
  s.version = Pgq::VERSION

  s.authors = ['Makarchev Konstantin']
  s.autorequire = 'init'

  s.description = 'Queues system for AR/Rails based on PgQ Skytools for PostgreSQL, like Resque on Redis. Rails 2.3 and 3 compatible.'
  s.summary = 'Queues system for AR/Rails based on PgQ Skytools for PostgreSQL, like Resque on Redis. Rails 2.3 and 3 compatible.'

  s.email = 'kostya27@gmail.com'
  s.homepage = 'http://github.com/kostya/pgq'

  s.require_paths = ['lib']

  s.add_dependency 'activerecord', '~> 7.1.0'
  s.add_dependency 'activesupport', '~> 7.1.0'
  s.add_dependency 'pg'

  s.add_development_dependency 'rake'
end
