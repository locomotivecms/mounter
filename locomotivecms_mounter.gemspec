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

  s.add_dependency 'tilt',                            '1.3.3'
  s.add_dependency 'haml',                            '3.2.0.rc.2'
  s.add_dependency 'sass',                            '~> 3.2.1'
  s.add_dependency 'compass',                         '~> 0.12.1'
  s.add_dependency 'coffee-script',                   '~> 2.2.0'
  s.add_dependency 'less',                            '~> 2.2.1'
  s.add_dependency 'RedCloth',                        '~> 4.2.3'
  s.add_dependency 'therubyracer',                    '~> 0.10.2'

  s.add_dependency 'activesupport',                   '~> 3.2.5'
  s.add_dependency 'i18n',                            '~> 0.6.0'
  s.add_dependency 'stringex',                        '~> 1.4.0'

  s.add_dependency 'multi_json',                      '~> 1.2.0'
  s.add_dependency 'httmultiparty',                   '~> 0.3.8'
  s.add_dependency 'json',                            '~> 1.6.5'
  s.add_dependency 'mime-types',                      '~> 1.19'

  s.add_dependency 'zip',                             '~> 2.0.2'
  s.add_dependency 'colorize',                        '~> 0.5.8'
  s.add_dependency 'logger'

  s.add_development_dependency 'rake',                '0.9.2'
  s.add_development_dependency 'rspec',               '~> 2.6.0'
  s.add_development_dependency 'mocha',               '0.9.12'
  s.add_development_dependency 'rack-test',           '~> 0.6.1'
  s.add_development_dependency 'ruby-debug-wrapper',  '~> 0.0.1'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'fakeweb'

  s.require_path = 'lib'

  s.files        = Dir.glob('lib/**/*')
end

