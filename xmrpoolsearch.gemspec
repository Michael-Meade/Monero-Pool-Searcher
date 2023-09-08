# frozen_string_literal: true

require_relative "lib/xmrpoolsearch/version"

Gem::Specification.new do |spec|
  spec.name          = "xmrpoolsearch"
  spec.version       = Xmrpoolsearch::VERSION
  spec.authors       = ["mike"]

  spec.summary       = "Search Monero mining pools "
  spec.description   = "Search Monero pools to find out how much an address made"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  spec.files = Dir['**/*'].keep_if { |file| File.file?(file) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_runtime_dependency "httparty"
  spec.add_runtime_dependency "gruff"
  spec.add_runtime_dependency "terminal-table"
  spec.add_runtime_dependency "bigdecimal"
  spec.add_runtime_dependency "json"
  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "colorize"
  
end
