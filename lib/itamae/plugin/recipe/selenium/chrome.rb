template '/etc/yum.repos.d/google-chrome.repo' do
  user 'root'
  owner 'root'
  group 'root'
  mode '644'
  variables disable_gpg_check: ['1', 'yes', 'true'].include?(ENV['CHROME_DISABLE_GPG_CHECK'].to_s.downcase)
end

unless node.platform_family == 'rhel' && node.platform_version.to_i >= 8
  raise 'This recipe supports only RHEL family with version >= 8.'
end

ENV['CHROME_VERSION'] = ENV['CHROME_VERSION'].to_s.empty? ? '152.0.7977.64' : ENV['CHROME_VERSION']

execute "yum install -y https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome-stable-#{ENV['CHROME_VERSION']}-1.x86_64.rpm" do
  user 'root'
  not_if "which google-chrome-stable && google-chrome-stable --version | cut -d ' ' -f 3 | egrep \"^#{Regexp.escape(ENV['CHROME_VERSION'])}$\""
end