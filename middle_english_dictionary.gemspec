
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "middle_english_dictionary/version"

Gem::Specification.new do |spec|
  spec.name          = "middle_english_dictionary"
  spec.version       = MiddleEnglishDictionary::VERSION
  spec.authors       = ["Bill Dueber"]
  spec.email         = ["bill@dueber.com"]

  spec.summary       = %q{Parse and use Middle English Dictionary data from raw sources}
  spec.description   = %q{Used in support of the Dromedary project}
  spec.homepage      = "https://github.com/mlibrary/middle_english_dictionary"


  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://gems.www.lib.umich.edu/"
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


  spec.add_dependency 'nokogiri', '~> 1.6'
  spec.add_dependency 'representable'
  spec.add_dependency 'multi_json'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"

end
