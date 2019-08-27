require 'net/http'

base_url = "https://chromedriver.storage.googleapis.com"
browser_version = run_command('sudo yum list | grep google-chrome-stable').stdout.split[1]
browser_version = Gem::Version.new(browser_version.to_s).segments[0..2].join('.')
driver_version_url = base_url + "/LATEST_RELEASE_#{browser_version}"
version = Net::HTTP.get_response(URI(driver_version_url)).body
download_url = base_url + "/#{version}/chromedriver_linux64.zip"

execute "download chromedriver-#{version}" do
  cwd '/tmp/itamae-plugin-recipe-selenium'
  command <<-EOF
    rm -Rf chromedriver_linux64-#{version}*
    curl -o chromedriver_linux64-#{version}.zip #{download_url}
  EOF
  not_if "test -e chromedriver_linux64-#{version}.zip"
end

execute "install chromedriver-#{version}" do
  cwd '/tmp/itamae-plugin-recipe-selenium'
  command <<-EOF
    unzip chromedriver_linux64-#{version}.zip
    sudo mv -f chromedriver /usr/local/bin/
  EOF
  not_if "/usr/local/bin/chromedriver -v | grep 'ChromeDriver #{version}'"
end
