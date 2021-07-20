require 'cocoapods-pdk8/hook/specification/set'
module Pod
  # The Specification provides a DSL to describe a Pod. A pod is defined as a
  # library originating from a source. A specification can support detailed
  # attributes for modules of code  through subspecs.
  #
  # Usually it is stored in files with `podspec` extension.
  #
  $SPECIFICATION_HASH_CACHE = Hash.new
  class Specification
    def self.from_file(path, subspec_name = nil)
      path = Pathname.new(path)
      unless path.exist?
        raise Informative, "No podspec exists at path `#{path}`."
      end
      return $SPECIFICATION_HASH_CACHE[path.expand_path] if $SPECIFICATION_HASH_CACHE[path.expand_path]

      string = File.open(path, 'r:utf-8', &:read)
      # Work around for Rubinius incomplete encoding in 1.9 mode
      if string.respond_to?(:encoding) && string.encoding.name != 'UTF-8'
        string.encode!('UTF-8')
      end
      specification = from_string(string, path, subspec_name)
      $SPECIFICATION_HASH_CACHE[path.expand_path] = specification
      return specification
    end

    $SPECIFICATION_FROM_STRING_HASH_CACHE = Hash.new

    def self.from_string(spec_contents, path, subspec_name = nil)
      path = Pathname.new(path).expand_path

      key = "#{path}"
      return $SPECIFICATION_FROM_STRING_HASH_CACHE[key] if $SPECIFICATION_FROM_STRING_HASH_CACHE[key]

      spec = nil
      case path.extname
      when '.podspec'
        Dir.chdir(path.parent.directory? ? path.parent : Dir.pwd) do
          spec = ::Pod._eval_podspec(spec_contents, path)
          unless spec.is_a?(Specification)
            raise Informative, "Invalid podspec file at path `#{path}`."
          end
        end
      when '.json'
        spec = Specification.from_json(spec_contents)
      else
        raise Informative, "Unsupported specification format `#{path.extname}` for spec at `#{path}`."
      end

      spec.defined_in_file = path
      spec.subspec_by_name(subspec_name, true)
      $SPECIFICATION_FROM_STRING_HASH_CACHE[key] = spec
      spec
    end
  end
end