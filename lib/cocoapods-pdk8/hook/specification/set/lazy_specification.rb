require 'cocoapods/resolver/lazy_specification'

# module Pod
#   class Specification
#     class Set
#       include SourceConfig::Mixin

#       # returns the highest versioned spec last
#       # alias all_specifications_fix all_specifications
#       def aall_specifications(warn_for_multiple_pod_sources, requirement)
#         @all_specifications ||= {}
#         @all_specifications[requirement] ||= begin
#           sources_by_version = {}
#           source_hash = {}
#           versions_by_source.each do |source, versions|
#             source_hash[source.url] ||= source
#             versions.each do |v|
#               next unless requirement.satisfied_by?(v)
#               (sources_by_version[v] ||= []) << source
#               if source_config.enable?
#                 if source_config.force_sources.include? source.url
#                   sources_by_version[v] = [source]
#                 else
#                   sources_by_version[v].each do |s|
#                     if source_config.force_sources.include? s.url
#                       sources_by_version[v] = [source]
#                     end
#                   end
#                 end
#               end
#             end
#           end


#           if warn_for_multiple_pod_sources
#             duplicate_versions = sources_by_version.select { |_version, sources| sources.count > 1 }

#             duplicate_versions.each do |version, sources|
#               UI.warn "Found multiple specifications for `#{name} (#{version})`:\n" +
#                 sources.
#                   map { |s| s.specification_path(name, version) }.
#                   map { |v| "- #{v}" }.join("\n")
#             end
#           end

#           # sort versions from high to low
#           sources_by_version.sort_by(&:first).flat_map do |version, sources|
#             # within each version, we want the prefered (first-specified) source
#             # to be the _last_ one
#             sources.reverse_each.map { |source| LazySpecification.new(name, version, source) }
#           end
#         end
#       end
#     end
#   end
# end