require 'net/http'

module Itamae
  module Plugin
    module Resource
      class SetupSeleniumDriver < Itamae::Resource::Base
        define_attribute :action, default: :run
        define_attribute :type, type: [String, Symbol], default: :chrome
        define_attribute :tmp_dir, type: String, default: '/tmp'
        define_attribute :install_dir, type: String, default: '/usr/local/bin/'

        def pre_action
          attributes.cwd = attributes.tmp_dir
          attributes.install_dir = File.join(attributes.install_dir, '/')
        end

        def set_current_attributes
          current.executed = false
        end

        def action_run(options)
          case attributes.type.to_sym
          when :chrome
            run_setup_chromedriver
          when :gecko
            run_setup_geckodriver
          end

          updated!
        end

        private

        def run_setup_chromedriver
          host = 'chromedriver.storage.googleapis.com'
          base_url = 'https://' + host
          browser_version = run_command('sudo yum list | grep google-chrome-stable').stdout.split[1]
          browser_version = Gem::Version.new(browser_version.to_s).segments[0..2].join('.')

          driver_version_url = base_url + "/LATEST_RELEASE_#{browser_version}"
          driver_version = Net::HTTP.get_response(URI(driver_version_url)).body
          
          # see https://stackoverflow.com/questions/70967207/selenium-chromedriver-cannot-construct-keyevent-from-non-typeable-key/70968668
          driver_version = '97.0.4692.71' if driver_version.start_with?('98.')

          download_url = base_url + "/#{driver_version}/chromedriver_linux64.zip"
          header = Net::HTTP.start(host) { |http| http.head("/#{driver_version}/chromedriver_linux64.zip") }
          etag = header['etag'][1...-1]

          Itamae.logger.info "browser version: #{browser_version}"
          Itamae.logger.info "driver version: #{driver_version}"
          Itamae.logger.debug "download url: #{download_url}"
          Itamae.logger.debug "etag: #{etag}"

          run_command_if_not(
            'download chromedriver',
            "echo '#{etag} chromedriver_linux64-#{driver_version}.zip' | md5sum -c -",
            <<-COMMANDS
              rm -Rf chromedriver_linux64-#{driver_version}*
              curl -o chromedriver_linux64-#{driver_version}.zip #{download_url}
            COMMANDS
          )

          run_command_if_not(
            'install chromedriver',
            "#{attributes.install_dir}chromedriver -v | grep 'ChromeDriver #{driver_version}'",
            <<-COMMANDS
              unzip chromedriver_linux64-#{driver_version}.zip
              sudo mv -f chromedriver #{attributes.install_dir}
            COMMANDS
          )
        end

        def run_setup_geckodriver
          base_url = "https://github.com/mozilla/geckodriver/releases"
          url = base_url + '/latest'
          response = nil
          5.times do
            response = Net::HTTP.get_response(URI(url))

            break unless response.is_a?(Net::HTTPRedirection)
            url = response['location']
          end
          driver_version = response.uri.to_s[/[^v]*$/]
          download_url = base_url + "/download/v#{driver_version}/geckodriver-v#{driver_version}-linux64.tar.gz"

          Itamae.logger.debug "driver version: #{driver_version}"
          Itamae.logger.debug "download url: #{download_url}"

          run_command_if_not(
            'download geckodriver',
            "test -e geckodriver-v#{driver_version}-linux64.tar.gz",
            <<-COMMANDS
              rm -Rf geckodriver-v#{driver_version}-linux64*
              curl -L -o geckodriver-v#{driver_version}-linux64.tar.gz #{download_url}
            COMMANDS
          )

          run_command_if_not(
            'install geckodriver',
            "#{attributes.install_dir}geckodriver -V | grep 'geckodriver #{driver_version}'",
            <<-COMMANDS
              tar zxf geckodriver-v#{driver_version}-linux64.tar.gz
              sudo mv -f geckodriver #{attributes.install_dir}
            COMMANDS
          )
        end

        def run_command_if_not(name, if_not_command, command)
          if do_not_run_command_because_of_not_if?(if_not_command)
            Itamae.logger.debug  "#{resource_type}[#{name}] Execution skipped because already done"
          else
            run_command command
            show_differences_message(name, 'executed', false, true)
          end
        end

        def do_not_run_command_because_of_not_if?(command)
          run_command(command, error: false).exit_status == 0
        end

        def show_differences_message(name, key, current_value, value)
          Itamae.logger.color :green do
            Itamae.logger.info "#{resource_type}[#{name}] #{key} will change from '#{current_value}' to '#{value}'"
          end
        end
      end
    end
  end
end
