include_recipe './tmp_directory'

setup_selenium_driver "setup chromedriver" do
  type :chrome
  tmp_dir '/tmp/itamae-plugin-recipe-selenium'
  install_dir '/usr/local/bin'
end
