# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "amazon2irc/version"

Gem::Specification.new do |spec|
  spec.name          = "amazon2irc"
  spec.version       = Amazon2irc::VERSION
  spec.authors       = ["jlee"]
  spec.email         = ["jlee@ruby.im"]

  spec.summary       = %q{ Filter Amazon Prime Day, Lightning, and Daily Deals to IRC.}
  spec.description   = %q{Pulls down Amazon deals via spidering or RSS feed, checks it for keywords, then sends it along to the irc chat specified. Stores previously seen deals with YAML, outputs new deals every 30s (not including chat delay). A quickly hacked Amazon Prime Day helper.}
  spec.homepage      = "https://github.com/jaycorpinc/amazon2irc"
  spec.license       = "PIRATE"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  #if spec.respond_to?(:metadata)
  #  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  #else
  #  raise "RubyGems 2.0 or newer is required to protect against " \
 #     "public gem pushes."
  #end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
