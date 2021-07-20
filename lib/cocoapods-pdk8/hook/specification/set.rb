module Pod
  class Specification
    class Set
      include SourceConfig::Mixin
      alias origin_specification_name specification_name
      def specification_name
        ## 这里可能存在的风险，但是目前可以再是不关心
        name
      end

      alias origin_versions_by_source versions_by_source
      def versions_by_source
        @fix_versions_by_source ||= begin
          force_sources = []
          vers_b_source = origin_versions_by_source
          vers_b_source.keys.each do |key|
            if source_config.force_sources.include? key.url
              force_sources << key
            end
          end
          result = {}
          vers_b_source.each do |key, value|
            result[key] = value
            force_sources.each do |src|
              result[key] = result[key] - vers_b_source[src] unless source_config.force_sources.include? key.url
            end
          end
          result
        end
      end
    end
  end
end