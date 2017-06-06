# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'text_extractor/version'

Gem::Specification.new do |spec|
  spec.name          = "text_extractor"
  spec.version       = TextExtractor::VERSION
  spec.authors       = ["Ilya Bazylchuk"]
  spec.email         = ["ilya.bazylchuk@gmail.com"]

  spec.summary       = %q{Extract text from different type of files}
  spec.description   = %q{Extract text from different type of files}
  spec.homepage      = "http://www.startwire.com"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'docsplit'
  spec.add_runtime_dependency 'posix-spawn'
  spec.add_runtime_dependency 'activesupport', '~> 4.2'

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-coolline"

  spec.extensions << 'ext/extconf.rb'
end
