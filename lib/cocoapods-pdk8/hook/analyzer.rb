
module Pod
  class Installer
    # Analyzes the Podfile, the Lockfile, and the sandbox manifest to generate
    # the information relative to a CocoaPods installation.
    #
    class Analyzer
      alias origin_update_repositories update_repositories
      def update_repositories
        threads = []
        sources.each do |source|
          threads << Thread.new {
            if source.updateable?
              sources_manager.update(source.name, true)
            else
              UI.message "Skipping `#{source.name}` update because the repository is not an updateable repository."
            end
          }
        end
        threads.each {|thr| thr.join}
        @specs_updated = true
      end
    end
  end
end
