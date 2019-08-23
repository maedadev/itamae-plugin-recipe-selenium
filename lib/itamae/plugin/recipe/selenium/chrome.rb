package 'google-chrome-stable' do
  user 'root'
end

execute 'yum update -y google-chrome-stable' do
  user 'root'
  not_if "which google-chrome-stable && google-chrome-stable --version | egrep 'Google Chrome (76|77)\.'"
end
