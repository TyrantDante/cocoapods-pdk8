module Pod
  class SourceConfig

    attr_accessor :force_xx_sources
    def force_sources
      @force_xx_sources ||= []
    end

    def add_force_source source
      raise "Donot try add a nil source to force sources" if source.nil?
      @force_xx_sources ||= []
      @force_xx_sources << source
    end

    def enable?
      !force_sources.empty?
    end

    attr_accessor :speed_up_enable

    def speed_up_enable?
      @speed_up_enable
    end

    def speed_up_enable enable
      @speed_up_enable = enable
    end
    
    attr_accessor :mutex_for_downloader
    def mutex_for_downloader
      @mutex_for_downloader ||= Mutex.new
    end

    class << self
      attr_writer :instance
      def instance
        @instance ||= new
      end
    end

    module Mixin
      def source_config
        SourceConfig.instance
      end
    end
  end
end