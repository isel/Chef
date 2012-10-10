gems = {
  'bundle' => '0.0.1',
  'amazon-ec2' => '0.9.17',
  'fog' => '1.1.2',
  'mongo' => '1.3.1',
  'bson' => '1.3.1',
  'rest-client' => '1.6.7',
  'xml-simple' => '1.1.1',
  'rr' => '1.0.4',
  'rspec' => '2.7.0',
  'simplecov' => '0.6.1'
}

class Chef::Recipe
  include LocalGems
end

puts gems_to_install(gems)

if node[:platform] == "ubuntu"
  bash 'Installing ruby gems' do
    code <<-EOF
apt-get install -y libyaml-dev
apt-cache policy libyaml-dev

gem install psych -v 1.3.2 --no-rdoc --no-ri

gem update --system

#{gems_to_install(gems).map { |gem, version| "gem install #{gem} -v #{version} --no-rdoc --no-ri \n" }.join}
    EOF
  end
else
  powershell 'Installing ruby gems' do
    script = <<-EOF
& "gem" 'update' '--system'
#{gems_to_install(gems).map { |gem, version| "& 'gem' 'install' '#{gem}' -v '#{version}' '--no-rdoc' '--no-ri' \n" }.join}
    EOF
    source(script)
  end
end