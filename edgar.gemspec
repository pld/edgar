s = Gem::Specification.new do |s|
  s.name         = 'edgar'
  s.version      = '0.0.5'
  s.date         = '2011-12-27'
  s.summary      = 'API for SEC Edgar search'
  s.description  = 'API for SEC Edgar search'
  s.authors      = ['Peter Lubell-Doughtie']
  s.email        = 'peter@helioid.com'
  s.files        = ['lib/edgar.rb', 'lib/result.rb']
  s.homepage     = 'http://www.helioid.com/'
end

s.add_dependency('nokogiri')
s

