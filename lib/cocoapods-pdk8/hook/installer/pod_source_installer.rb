module Pod
  class Installer
    # Controller class responsible of installing the activated specifications
    # of a single Pod.
    #
    # @note This class needs to consider all the activated specs of a Pod.
    #
    class PodSourceInstaller
      def download_source
        if root_spec.source[:git] =~ /http/
          source = root_spec.attributes_hash["source"]
          # 替换
          if source["git"].include? "https://g.hz.netease.com"
            source["git"]["https://g.hz.netease.com"] = "ssh://git@g.hz.netease.com:22222"
          end
    
          if source["git"].include? "http://g.hz.netease.com"
            source["git"]["http://g.hz.netease.com"] = "ssh://git@g.hz.netease.com:22222"
          end
        end
        download_result = Downloader.download(download_request, root, :can_cache => can_cache?)

        if (specific_source = download_result.checkout_options) && specific_source != root_spec.source
          sandbox.store_checkout_source(root_spec.name, specific_source)
        end
      end
    end
  end
end