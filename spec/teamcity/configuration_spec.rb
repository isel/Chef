require 'spec_helper'

require_relative '../../cookbooks/teamcity/libraries/configuration'

include Configuration

describe "Configuration" do
  let(:file) { 'file path' }
  let(:source_xml) { <<eof
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE server SYSTEM "main-config.dtd">
<server>
  <version number="544" />
  <auth-type>
    <free-registration allowed="true" />
  </auth-type>
</server>
eof
  }
  let(:result_xml) { <<eof
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE server SYSTEM "main-config.dtd">
<server>
  <version number="544" />
  <auth-type>
    <free-registration allowed="false" />
    <guest-login allowed="true" guest-username="guest" />
    <login-description></login-description>
    <login-module class="jetbrains.buildServer.serverSide.impl.auth.LDAPLoginModule" />
  </auth-type>
</server>
eof
  }

  it "should set the authorization" do
    stub(File).read(file) { source_xml }

    f = Object.new
    mock(File).open(file, 'w+').yields(f)
    mock(f).puts result_xml

    change_authorization(file)
  end

end