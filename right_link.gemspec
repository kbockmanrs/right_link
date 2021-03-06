# -*- mode: ruby; encoding: utf-8 -*-

require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name        = 'right_link'
  s.version     = '5.9.0'
  s.platform    = Gem::Platform::RUBY
  
  s.authors     = ['RightScale']
  s.email       = 'support@rightscale.com'
  s.homepage    = 'https://github.com/rightscale/right_link'

  s.summary     = %q{RightScale management agent.}
  s.description = %q{A daemon that connects systems to the RightScale cloud management platform.}
  
  s.required_rubygems_version = '>= 1.3.7'

  s.add_runtime_dependency('right_agent', '~> 0.10')
  s.add_runtime_dependency('right_scraper', '~> 3.0')
  s.add_runtime_dependency('right_popen', '~> 1.0')
  s.add_runtime_dependency('right_http_connection', '~> 1.3')
  s.add_runtime_dependency('right_support', '~> 2.0')

  s.add_runtime_dependency('chef', '>= 0.10.10')
  s.add_runtime_dependency('encryptor', '~> 1.1')
  s.add_runtime_dependency('trollop')
  s.add_runtime_dependency('extlib', '~> 0.9.15')

  if s.platform.to_s =~ /mswin|mingw/
    s.add_runtime_dependency('win32-api', '~> 1.4.5')
    s.add_runtime_dependency('windows-api', '~> 0.4.0')
    s.add_runtime_dependency('windows-pr', '~> 1.0.8')
    s.add_runtime_dependency('win32-dir', '~> 0.3.5')
    s.add_runtime_dependency('win32-eventlog', '~> 0.5.2')
    s.add_runtime_dependency('ruby-wmi', '~> 0.2.2')
    s.add_runtime_dependency('win32-process', '~> 0.6.1')
    s.add_runtime_dependency('win32-pipe', '~> 0.2.1')
    s.add_runtime_dependency('win32-open3', '~> 0.3.2')
    s.add_runtime_dependency('win32-service', '~> 0.7.2')
  end

  s.files = Dir.glob('Gemfile') +
            Dir.glob('Gemfile.lock') +
            Dir.glob('init/*') +
            Dir.glob('actors/*.rb') +
            Dir.glob('bin/*') +
            Dir.glob('ext/Rakefile') +
            Dir.glob('lib/chef/windows/**/*.cs') +
            Dir.glob('lib/chef/windows/**/*.csproj') +
            Dir.glob('lib/chef/windows/bin/*.dll') +
            Dir.glob('lib/chef/windows/**/*.ps1') +
            Dir.glob('lib/chef/windows/**/*.sln') +
            Dir.glob('lib/chef/windows/**/*.txt') +
            Dir.glob('lib/chef/windows/**/*.xml') +
            Dir.glob('lib/**/*.pub') +
            Dir.glob('scripts/*') +
            Dir.glob('lib/instance/cook/*.crt')

  s.executables = Dir.glob('bin/*').map { |f| File.basename(f) }
  s.extensions = ["ext/Rakefile"]
end
