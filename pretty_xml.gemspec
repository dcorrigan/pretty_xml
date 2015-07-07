Gem::Specification.new do |s|
  s.name        = "pretty_xml"
  s.version     = '0.0.2.1'
  s.authors     = ["Dan Corrigan"]
  s.email       = ["df.corrigan@gmail.com"]
  s.homepage    = "http://github.com/dcorrigan/pretty_xml"
  s.summary     = "For printing human-readable XML docs"
  s.description = "Accepts element lists as block, compact, and inline parameters and a tab parameter to create a new instance. When pp method is called with a Nokogiri::XML::Document or XML string as argument, the method returns a string formatted according to the logic of the element lists. For optional parameters, see README."

  s.add_development_dependency('rake')
  s.add_development_dependency("minitest")
  s.add_development_dependency("pry")
  s.add_development_dependency('rspec')
  s.add_dependency("nokogiri")

  s.files        = Dir.glob("{lib,etc}/**/*") + %w(LICENSE README.md)
end
