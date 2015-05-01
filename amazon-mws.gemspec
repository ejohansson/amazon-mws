# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name = %q{amazon-mws}
  s.version = "0.2.0"

  s.authors     = ["David Michael", "A. Edward Wible", "Eric Johansson"]
  s.email       = ["david.michael@sonymusic.com", "aewible@gmail.com", ejohansson@novarata.com]
  s.homepage    = "http://github.com/aew/amazon-mws"
  s.summary     = %q{A Ruby Wrapper for the Amazon MWS API}
  s.description = %q{A Ruby Wrapper for the Amazon MWS API}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features,examples}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "ruby-hmac"
  s.add_dependency "roxml"
  s.add_dependency "xml-simple"
  s.add_dependency "builder"
end
