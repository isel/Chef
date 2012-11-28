require 'xmlsimple'

module Configuration

  def change_authorization(file)
    xs = XmlSimple.new({
      :RootName => 'server',
      :XmlDeclaration => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE server SYSTEM \"main-config.dtd\">"
    })

    ref = xs.xml_in(File.read(file))
    authorization = ref['auth-type']

    authorization[0]['free-registration'][0]['allowed'] ='false'
    authorization[0]['guest-login'] = [{ 'allowed' => 'true', 'guest-username' => 'guest' }]
    authorization[0]['login-description'] = [{}]
    authorization[0]['login-module'] = [{ 'class' => 'jetbrains.buildServer.serverSide.impl.auth.LDAPLoginModule' }]

    File.open(file, 'w+') { |f| f.puts xs.xml_out(ref) }
  end


end