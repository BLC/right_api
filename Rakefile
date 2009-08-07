require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "#{ENV['GITHUB'] ? 'moneypools-' : ''}right_api"
    gem.summary = %Q{A ruby wrapper for the RightScale api}
    gem.description = "A ruby wrapper for the RightScale api"
    gem.email = "mpdev@businesslogic.com"
    gem.homepage = "http://github.com/moneypools/right_api"
    gem.authors = ["MoneyPools"]
    gem.add_dependency('hpricot')
    gem.add_dependency('activesupport')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "right_api #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => ['gemspec', 'build']