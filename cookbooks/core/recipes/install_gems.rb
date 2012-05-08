gems = [
  {'gem' => 'fog',                 'version' => '1.1.1'},
  {'gem' => 'amazon-ec2',          'version' => '0.9.17'},
  {'gem' => 'bundle',              'version' => '0.0.1'},
  {'gem' => 'bson',                'version' => '1.3.1'},
  {'gem' => 'mongo',               'version' => '1.3.1'},
  {'gem' => 'excon',               'version' => '0.7.6'},
  {'gem' => 'multi_json',          'version' => '1.0.3'},
  {'gem' => 'rest-client',         'version' => '1.6.7'},
  {'gem' => 'xml-simple',          'version' => '1.1.1'},
  {'gem' => 'net-ssh',             'version' => '2.2.1'},
  {'gem' => 'net-scp',             'version' => '1.0.4'},
  {'gem' => 'rr',                  'version' => '1.0.4'},
  {'gem' => 'rspec',               'version' => '2.7.0'},
  {'gem' => 'rspec-core',          'version' => '2.7.1'},
  {'gem' => 'rspec-expectations',  'version' => '2.7.0'},
  {'gem' => 'rspec-mocks',         'version' => '2.7.0'},
  {'gem' => 'simplecov-html',      'version' => '0.5.3'},
  {'gem' => 'simplecov',           'version' => '0.6.1'},
]

if node[:platform] == "ubuntu"
  bash 'Installing ruby gems' do
    code <<-EOF
apt-get install -y libyaml-dev
apt-cache policy libyaml-dev

gem install psych -v 1.3.2 --no-rdoc --no-ri

gem update --system

#{gems.map {|g| "gem install #{g['gem']} -v #{g['version']} --no-rdoc --no-ri \n"}.join}
    EOF
  end
else
  powershell 'Installing ruby gems' do
    script = <<-EOF
& "gem" 'update' '--system'
#{gems.map {|g| "& 'gem' 'install' '#{g['gem']}' -v '#{g['version']}' '--no-rdoc' '--no-ri' \n"}.join}
    EOF
    source(script)
  end
end