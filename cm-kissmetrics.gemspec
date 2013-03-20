require File.expand_path('../lib/cm-kissmetrics/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Drew Gillson"]
  gem.email         = ["drew.gillson@gmail.com"]
  gem.description   = %q{Quickly load historic subscriber behavior from CampaignMonitor into KISSMetrics}
  gem.summary       = %q{Integrate CampaignMonitor and KISSMetrics}
  gem.homepage      = "https://github.com/drewgillson/cm-kissmetrics"
  gem.license       = 'MIT'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.name          = "cm-kissmetrics"
  gem.version       = CmKissmetrics::VERSION
end
