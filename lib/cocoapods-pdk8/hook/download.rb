module Pod
  module Downloader
    # The class responsible for managing Pod downloads, transparently caching
    # them in a cache directory.
    #
    class Cache
      include SourceConfig::Mixin
      def ensure_matching_version
        version_file = root + 'VERSION'

        source_config.mutex_for_downloader.synchronize {
          version = version_file.read.strip if version_file.file?
          root.rmtree if version != Pod::VERSION && root.exist?
          root.mkpath
  
          version_file.open('w') { |f| f << Pod::VERSION }
        }
      end
    end
  end
end