class ::Webdrivers::Chromedriver
  class << self
    attr_writer :browser_version

    alias :__browser_version__ :browser_version
    def browser_version
      @browser_version || __browser_version__
    end
  end
end