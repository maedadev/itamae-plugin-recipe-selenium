require 'webdrivers/geckodriver'
require_relative 'patches/webdrivers/common'
require_relative 'patches/webdrivers/system'

::Webdrivers::System.target_os = 'linux'
version = ::Webdrivers::Geckodriver.latest_version
download_url = ::Webdrivers::Geckodriver.send(:download_url)

execute "download geckodriver-#{version}" do
  cwd '/tmp/itamae-plugin-recipe-selenium'
  command <<-EOF
    rm -Rf geckodriver-v#{version}-linux64*
    curl -L -o geckodriver-v#{version}-linux64.tar.gz #{download_url}
    sha256sum geckodriver-v#{version}-linux64.tar.gz > geckodriver-v#{version}-linux64_sha256.txt
  EOF
  not_if "test -e geckodriver-v#{version}-linux64_sha256.txt && sha256sum -c geckodriver-v#{version}-linux64_sha256.txt"
end

execute "install geckodriver-#{version}" do
  cwd '/tmp/itamae-plugin-recipe-selenium'
  command <<-EOF
    tar zxf geckodriver-v#{version}-linux64.tar.gz
    sudo mv -f geckodriver /usr/local/bin/
  EOF
  not_if "/usr/local/bin/geckodriver -V | grep 'geckodriver #{version}'"
end
