class ::Webdrivers::System
  class << self
    attr_writer :target_os

    alias :__platform__ :platform
    def platform
      return __platform__ if @target_os.nil?

      if @target_os == 'linux' || @target_os == 'mac' || @target_os == 'win'
        @target_os
      else
        raise NotImplementedError, "Your OS '#{@target_os}' is not supported by webdrivers gem."
      end
    end
  end
end