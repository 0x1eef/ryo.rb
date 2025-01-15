require "bundler/gem_tasks"
require "bundler/setup"

desc "Run CI tasks"
task :ci do
  sh "bundle exec rubocop"
  sh "bundle exec rspec spec/"
end

desc "Run tests"
task :test do
  sh "bundle exec rspec spec/"
end
task default: :test
