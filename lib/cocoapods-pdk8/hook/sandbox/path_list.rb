module Pod
  class Sandbox
    # The PathList class is designed to perform multiple glob matches against
    # a given directory. Basically, it generates a list of all the children
    # paths and matches the globs patterns against them, resulting in just one
    # access to the file system.
    #
    # @note   A PathList once it has generated the list of the paths this is
    #         updated only if explicitly requested by calling
    #         {#read_file_system}
    #
    class PathList
      def read_file_system

        unless root.exist?
          puts caller
          raise Informative, "Attempt to read non existent folder `#{root}`."
        end
        dirs = []
        files = []
        root_length = root.cleanpath.to_s.length + File::SEPARATOR.length
        escaped_root = escape_path_for_glob(root)
        Dir.glob(escaped_root + '**/*', File::FNM_DOTMATCH).each do |f|
          directory = File.directory?(f)
          # Ignore `.` and `..` directories
          next if directory && f =~ /\.\.?$/

          f = f.slice(root_length, f.length - root_length)
          next if f.nil?

          (directory ? dirs : files) << f
        end

        dirs.sort_by!(&:upcase)
        files.sort_by!(&:upcase)

        @dirs = dirs
        @files = files
        @glob_cache = {}
      end
    end
  end
end