#!/usr/bin/env gem build
# encoding: utf-8

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'locomotive/mounter/version'

Gem::Specification.new do |s|
  s.name        = 'locomotivecms_mounter'
  s.version     = Locomotive::Mounter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Didier Lafforgue']
  s.email       = ['didier@nocoffee.fr']
  s.homepage    = 'http://www.locomotivecms.com'
  s.summary     = 'LocomotiveCMS Mounter'
  s.description = 'Mount any LocomotiveCMS site, from a template on the filesystem, a zip file or even an online engine'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'locomotivecms_mounter'

  s.add_dependency 'tilt',                           '1.4.1'
  s.add_dependency 'sprockets',                      '~> 2.0'
  s.add_dependency 'sprockets-sass'
  s.add_dependency 'haml',                           '~> 4.0.5'
  s.add_dependency 'sass',                           '>= 3.2'
  s.add_dependency 'compass',                        '~> 0.12.2'
  s.add_dependency 'coffee-script',                  '~> 2.2.0'
  s.add_dependency 'less',                           '~> 2.2.1'
  s.add_dependency 'RedCloth',                       '~> 4.2.3'

  s.add_dependency 'tzinfo',                         '~> 0.3.29'
  s.add_dependency 'chronic',                        '~> 0.10.2'

  s.add_dependency 'activesupport',                  '~> 3.2.18'
  s.add_dependency 'i18n',                           '~> 0.6.0'
  s.add_dependency 'stringex',                       '~> 2.0.3'

  s.add_dependency 'multi_json',                     '~> 1.8.4'
  s.add_dependency 'httmultiparty',                  '0.3.10'
  s.add_dependency 'json',                           '~> 1.8.0'
  s.add_dependency 'mime-types',                     '~> 1.19'

  s.add_dependency 'zip',                            '~> 2.0.2'
  s.add_dependency 'colorize',                       '~> 0.5.8'
  s.add_dependency 'logger'

  s.add_development_dependency 'rake',               '0.9.2'
  s.add_development_dependency 'rspec',              '~> 2.14.1'
  s.add_development_dependency 'rack-test',          '~> 0.6.1'
  s.add_development_dependency 'ruby-debug-wrapper', '~> 0.0.1'
  s.add_development_dependency 'vcr',                '2.4.0'
  s.add_development_dependency 'therubyracer',       '~> 0.11.4'
  s.add_development_dependency 'webmock',            '1.9.3'

  s.require_path = 'lib'

  s.files = Dir.glob('lib/**/*')
end