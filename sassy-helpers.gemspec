# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sassyversion', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Peter Krusche"]
  gem.email         = ["pkrusche@gmail.com"]
  gem.summary = %q{Model conversion helpers for SaSSy/MATLAB and XPP}
  gem.description = %q{Model conversion helpers for SaSSy/MATLAB and XPP.
    See http://www2.warwick.ac.uk/fac/sci/systemsbiology/research/software/
  }
  gem.license = "MIT"
  gem.homepage      = "http://mass-communicating.com/code/sassy-helpers.html"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sassy-helpers"
  gem.require_paths = ["lib"]
  gem.version       = SassyHelpers::VERSION

  gem.add_development_dependency "rspec", "~> 2.6"
  gem.add_development_dependency "awesome_print"
  gem.add_dependency "treetop", "~> 1.4"
  # gem.add_dependency "nokogiri"
end
