include_recipe './tmp_directory'

package 'unzip' do
  user 'root'
end

setup_selenium_driver "setup chromedriver" do
  type :chrome
  tmp_dir '/tmp/itamae-plugin-recipe-selenium'
  install_dir '/usr/local/bin'
end
