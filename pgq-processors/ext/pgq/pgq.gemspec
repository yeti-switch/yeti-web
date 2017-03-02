# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + '/lib/pgq/version'

Gem::Specification.new do |s|
  s.name = %q{pgq}
  s.version = Pgq::VERSION

  s.authors = ['Makarchev Konstantin']
  s.autorequire = %q{init}
  
  s.description = %q{Queues system for AR/Rails based on PgQ Skytools for PostgreSQL, like Resque on Redis. Rails 2.3 and 3 compatible.}
  s.summary = %q{Queues system for AR/Rails based on PgQ Skytools for PostgreSQL, like Resque on Redis. Rails 2.3 and 3 compatible.}
  
  s.email = %q{kostya27@gmail.com}
  s.homepage = %q{http://github.com/kostya/pgq}

  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', '>= 4.0.2'
  s.add_dependency 'activerecord', '>= 4.0.2'
  s.add_dependency 'pg'

  s.add_development_dependency 'rake'
end