module LocalGems
  def installed
    gem_list = `gem list --local`

    gems = {}
    gem_list.split("\n").each do |g|
      name, all_versions = g.split(' (')
      versions = all_versions.gsub(')', '').split(', ')
      gems[name] = versions.map { |v| v.split(' ').first }
    end
    gems
  end

  def gems_to_install(gems)
    installed_gems = installed
    gems.select { |gem, version| installed_gems[gem].nil? || !installed_gems[gem].include?(version) }
  end
end