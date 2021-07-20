module Pod
  # A Requirement is a set of one or more version restrictions of a
  # {Dependency}.
  #
  # It is based on the RubyGems class adapted to support CocoaPods specific
  # information.
  #
  # @todo Move support about external sources and head information here from
  #       the Dependency class.
  #
  class Requirement < Pod::Vendor::Gem::Requirement
    # module Pod::Specification::Set - all_specifications[requirement]
    # 如上所示，当requirement做为key的时候，实际上只需要requirements的内容是一样既可以认为是一样的，而不需要整个Requirement的对象一样
    def eql? other
      @requirements.eql? other.requirements
    end
  end
end