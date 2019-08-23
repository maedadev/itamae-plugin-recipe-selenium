# case `sudo yum list | grep google-chrome-stable`.split[1]
# when /76\..*/
#   version = '76.0.3809.68'
# when /77\..*/
#   version = '77.0.3865.10'
# else
#   version = '77.0.3865.10'
#   puts "現在インストールされている Chrome のバージョンは #{`google-chrome-stable --version`.strip}"
# end

require 'webdrivers/chromedriver'
require_relative 'patches/webdrivers/common'
require_relative 'patches/webdrivers/system'
require_relative 'patches/webdrivers/chromedriver'

::Webdrivers::System.target_os = 'linux'

browser_version = run_command('sudo yum list | grep google-chrome-stable').stdout.split[1]
::Webdrivers::Chromedriver.browser_version = browser_version

version = ::Webdrivers::Chromedriver.latest_version
download_url = ::Webdrivers::Chromedriver.send(:download_url)

execute "download chromedriver-#{version}" do
  cwd '/tmp/itamae-plugin-recipe-selenium'
  command <<-EOF
    rm -Rf chromedriver_linux64-#{version}*
    curl -o chromedriver_linux64-#{version}.zip #{download_url}
    sha256sum chromedriver_linux64-#{version}.zip > chromedriver_linux64-#{version}_sha256.txt
  EOF
  not_if "test -e chromedriver_linux64-#{version}_sha256.txt && sha256sum -c chromedriver_linux64-#{version}_sha256.txt"
end

execute "install chromedriver-#{version}" do
  cwd '/tmp/itamae-plugin-recipe-selenium'
  command <<-EOF
    unzip chromedriver_linux64-#{version}.zip
    sudo mv -f chromedriver /usr/local/bin/
  EOF
  not_if "/usr/local/bin/chromedriver -v | grep 'ChromeDriver #{version}'"
end
