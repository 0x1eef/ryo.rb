require "./lib/proto/version"
Gem::Specification.new do |gem|
  gem.name = "proto.rb"
  gem.authors = ["0x1eef"]
  gem.email = ["0x1eef@protonmail.com"]
  gem.homepage = "https://github.com/0x1eef/proto.rb#readme"
  gem.version = Proto::VERSION
  gem.licenses = ["MIT"]
  gem.files = `git ls-files`.split($/)
  gem.require_paths = ["lib"]
  gem.description = "proto.rb implements prototype-based inheritance in pure Ruby"
  gem.summary = gem.description
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "redcarpet", "~> 3.5"
  gem.add_development_dependency "rspec", "~> 3.10"
  gem.add_development_dependency "standard", "~> 1.9"
end
