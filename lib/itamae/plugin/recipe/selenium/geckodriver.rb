include_recipe './tmp_directory'

setup_selenium_driver "setup geckodriver" do
  type :gecko
  tmp_dir '/tmp/itamae-plugin-recipe-selenium'
  install_dir '/usr/local/bin'
end
