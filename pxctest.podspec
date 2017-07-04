Pod::Spec.new do |s|
  s.name           = 'pxctest'
  s.version        = `./scripts/get_version.sh`
  s.summary        = 'Execute tests in parallel on multiple iOS Simulators'
  s.homepage       = 'https://github.com/plu/pxctest'
  s.license        = { :type => 'MIT', :file => 'LICENSE' }
  s.author         = { 'Johannes Plunien' => 'plu@pqpq.de' }
  s.source         = { :http => "#{s.homepage}/releases/download/#{s.version}/portable_pxctest.zip" }
  s.preserve_paths = '*'
end
