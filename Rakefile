task :default => :test

desc "Run tests"
task :test do
  sh "ruby -Ilib test/authorization_test.rb"
end

begin
  require "mg"
  MG.new("sinatra-authorization.gemspec")
rescue LoadError
end
