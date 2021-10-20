version = ENV['CHROME_VERSION'] || '94.0.4606.81'

template '/etc/yum.repos.d/google-chrome.repo' do
  user 'root'
  owner 'root'
  group 'root'
  mode '644'
end

execute "yum install -y https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome-stable-#{version}-1.x86_64.rpm" do
  user 'root'
  not_if "which google-chrome-stable && google-chrome-stable --version | cut -d ' ' -f 3 | egrep \"^#{version}$\""
end

execute 'yum update -y google-chrome-stable' do
  user 'root'
  not_if "which google-chrome-stable && google-chrome-stable --version | egrep 'Google Chrome (90|91|92|93|94)\.'"
end
