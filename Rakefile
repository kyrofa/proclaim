begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Proclaim'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'



Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.verbose = false
  if ENV["TEST"].nil?
    t.pattern = 'test/**/*_test.rb'
  else
    t.pattern = ENV["TEST"]
  end
end

namespace :test do
  Rails::TestTask.new(:generators) do |t|
    t.pattern = "test/lib/generators/**/*_test.rb"
  end

  Rails::TestTask.new(:units) do |t|
    t.pattern = 'test/{models,helpers,unit}/**/*_test.rb'
  end

  Rails::TestTask.new(:functionals) do |t|
    t.pattern = 'test/{controllers,mailers,functional}/**/*_test.rb'
  end

  Rails::TestTask.new(:integration) do |t|
    t.pattern = 'test/integration/**/*_test.rb'
  end

  namespace :integration do
    Rails::TestTask.new(:js) do |t|
      t.pattern = 'test/integration/with_javascript/**/*_test.rb'
    end

    Rails::TestTask.new(:no_js) do |t|
      t.pattern = 'test/integration/without_javascript/**/*_test.rb'
    end
  end
end

task default: :test
