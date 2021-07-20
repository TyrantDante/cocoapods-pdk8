module Pod
  class TimeProfiler
    #
    # Hash {
    #   stage:{
    #     :start => Date,
    #     step => {
    #       :start
    #       :end
    #     }
    #   }
    # }
    attr_accessor :time_line
    def add_milestone_start stage, step
      @time_line ||= Hash.new
      @time_line[stage] ||= begin 
        rs = Hash.new
        rs
      end
      @time_line[stage][step] = {
        :start => Time.new.getutc.to_i
      }
    end

    def add_milestone_stop stage, step
      raise "timeline is not start" unless @time_line
      raise "stage #{stage} is not start" unless @time_line[stage]
      raise "step #{step} is not start" unless @time_line[stage][step]
      @time_line[stage][step][:stop] = Time.new.getutc.to_i
    end
    # - total: 1s
    # -- prepare: 0s
    # -- resolve_dependencies: 0s
    # --- run_source_provider_hooks: 0s
    # --- create_analyzer: 0s
    # --- analyze: 1s
    # -- download_dependencies: 0s
    # --- install_pod_sources: 0s
    # --- run_podfile_pre_install_hooks: 0s
    # --- clean_pod_sources: 0s
    # -- validate_targets: 0s
    # -- integrate: 0s
    # --- generate_pods_project: 0s
    # --- integrate_user_project: 0s
    # -- write_lockfiles: 0s
    # -- perform_post_install_actions: 0s
    def format_prints
      result = []
      total_line = @time_line[total_stage]
      if total_line
        result << "- total: #{total_line[default_step][:stop] - total_line[default_step][:start]}s".yellow
      end
      stages.each do |stage|
        stage_line = @time_line[stage]
        if stage_line
          stage_cost = stage_line[default_step][:stop] - stage_line[default_step][:start]
          result << "-- #{stage}: #{stage_cost}s".yellow
          stage_line.each do |step, values|
            if step != default_step
              result << "--- #{step}: #{values[:stop] - values[:start]}s"
            end
          end
        end
      end
      result
    end

    def format
      result = Hash.new
      total_line = @time_line[total_stage]
      if total_line
        result["total"] = total_line[default_step][:stop] - total_line[default_step][:start]
      end
      stages.each do |stage|
        stage_line = @time_line[stage]
        if stage_line
          stage_cost = stage_line[default_step][:stop] - stage_line[default_step][:start]
          result[stage] = stage_cost
        end
      end
      result
    end

    def total_stage
      "total_stage"
    end

    def default_step
      "default_step"
    end

    def stages
      [
        stage_prepare,
        stage_resolve_dependencies,
        stage_download_dependencies,
        stage_validate_targets,
        stage_show_skip_pods_project_generation_message,
        stage_integrate,
        stage_write_lockfiles,
        stage_perform_post_install_actions
      ]
    end

    def stage_prepare
      "prepare"
    end

    def stage_resolve_dependencies
      "resolve_dependencies"
    end

    def stage_download_dependencies
      "download_dependencies"
    end

    def stage_validate_targets
      "validate_targets"
    end

    def stage_show_skip_pods_project_generation_message
      "show_skip_pods_project_generation_message"
    end

    def stage_integrate
      "integrate"
    end

    def stage_write_lockfiles
      "write_lockfiles"
    end

    def stage_perform_post_install_actions
      "perform_post_install_actions"
    end

    class << self
      attr_writer :instance
      def instance
        @instance ||= new
      end
    end

    module Mixin
      def time_profiler
        return TimeProfiler.instance
      end
    end
  end
end