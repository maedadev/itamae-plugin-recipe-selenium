template '/etc/yum.repos.d/google-chrome.repo' do
  user 'root'
  owner 'root'
  group 'root'
  mode '644'
end

package 'google-chrome-stable' do
  user 'root'
end

execute 'yum update -y google-chrome-stable' do
  user 'root'
  not_if "which google-chrome-stable && google-chrome-stable --version | egrep 'Google Chrome (87|88|89|90|91)\.'"
end
