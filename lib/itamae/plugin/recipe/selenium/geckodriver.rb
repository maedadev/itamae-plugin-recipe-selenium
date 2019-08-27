require 'net/http'

base_url = "https://github.com/mozilla/geckodriver/releases"
url = base_url + '/latest'
response = nil
5.times do
  response = Net::HTTP.get_response(URI(url))

  break unless response.is_a?(Net::HTTPRedirection) 
  url = response['location']
end
version = response.uri.to_s[/[^v]*$/]
download_url = base_url + "/download/v#{version}/geckodriver-v#{version}-linux64.tar.gz"

execute "download geckodriver-#{version}" do
  cwd '/tmp/itamae-plugin-recipe-selenium'
  command <<-EOF
    rm -Rf geckodriver-v#{version}-linux64*
    curl -L -o geckodriver-v#{version}-linux64.tar.gz #{download_url}
  EOF
  not_if "test -e geckodriver-v#{version}-linux64.tar.gz"
end

execute "install geckodriver-#{version}" do
  cwd '/tmp/itamae-plugin-recipe-selenium'
  command <<-EOF
    tar zxf geckodriver-v#{version}-linux64.tar.gz
    sudo mv -f geckodriver /usr/local/bin/
  EOF
  not_if "/usr/local/bin/geckodriver -V | grep 'geckodriver #{version}'"
end
