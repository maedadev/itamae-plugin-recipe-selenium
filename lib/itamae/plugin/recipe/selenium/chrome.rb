template '/etc/yum.repos.d/google-chrome.repo' do
  user 'root'
  owner 'root'
  group 'root'
  mode '644'
  variables disable_gpg_check: ['1', 'yes', 'true'].include?(ENV['CHROME_DISABLE_GPG_CHECK'].to_s.downcase)
end

if ENV['CHROME_VERSION'].to_s.empty?
  ENV['CHROME_VERSION'] = '125.0.6422.141'

  execute "yum install -y https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome-stable-#{ENV['CHROME_VERSION']}-1.x86_64.rpm" do
    user 'root'
    not_if "which google-chrome-stable && google-chrome-stable --version | egrep 'Google Chrome (123|124|125)\.'"
  end
else
  execute "yum install -y https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome-stable-#{ENV['CHROME_VERSION']}-1.x86_64.rpm" do
    user 'root'
    not_if "which google-chrome-stable && google-chrome-stable --version | cut -d ' ' -f 3 | egrep \"^#{ENV['CHROME_VERSION']}$\""
  end
end
