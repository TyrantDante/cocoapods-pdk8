module Pod
  class Podfile
    module DSL
      include SourceConfig::Mixin

      def force_source url
        SourceConfig.instance.add_force_source url
        source url
      end

      def speed_up_enable enable
        SourceConfig.instance.speed_up_enable enable
      end
    end
  end
end