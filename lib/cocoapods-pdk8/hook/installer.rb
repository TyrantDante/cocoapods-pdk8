require 'thread'
require 'cocoapods-pdk8/hook/installer/pod_source_installer'

module Pod
  class Installer
    include SourceConfig::Mixin
    attr_accessor :mutex
    def install_pod_sources
      @mutex = source_config.mutex_for_downloader
      @installed_specs = []
      pods_to_install = sandbox_state.added | sandbox_state.changed

      download_queue = Queue.new
      root_specs.sort_by(&:name).each do |spec|
        download_queue.push spec
      end

      threads = []
      (1..12).each do |thread_index|
        threads << Thread.new {
          while not download_queue.empty?
            spec = download_queue.pop(true)
            last_time = Time.new.to_i
            if pods_to_install.include? spec.name
              pods_to_install_include_download spec,thread_index
            else
              pods_to_install_exclude_download spec,thread_index
            end
            puts "finish #{spec.name} cost: #{Time.new.to_i - last_time}s".green
          end
        }
      end
      threads.map(&:join)
    end

    def title_options
      { :verbose_prefix => '-> '.green }
    end

    def pods_to_install_include_download spec,thread_index
      title = ""
      if sandbox_state.changed.include?(spec.name) && sandbox.manifest
        title = pods_to_install_include_changed_title spec
      else
        title = pods_to_install_include_added_title spec
      end
      UI.titled_section("#{thread_index}:#{title}".green, title_options) do
        install_source_of_pod(spec.name)
      end
    end

    def pods_to_install_include_changed_title spec
      current_version = spec.version
      previous_version = sandbox.manifest.version(spec.name)
      has_changed_version = current_version != previous_version
      current_repo = analysis_result.specs_by_source.detect { |key, values| break key if values.map(&:name).include?(spec.name) }
      current_repo &&= (Pod::TrunkSource::TRUNK_REPO_NAME if current_repo.name == Pod::TrunkSource::TRUNK_REPO_NAME) || current_repo.url || current_repo.name
      previous_spec_repo = sandbox.manifest.spec_repo(spec.name)
      has_changed_repo = !previous_spec_repo.nil? && current_repo && !current_repo.casecmp(previous_spec_repo).zero?
      title = "Installing #{spec.name} #{spec.version}"
      title << " (was #{previous_version} and source changed to `#{current_repo}` from `#{previous_spec_repo}`)" if has_changed_version && has_changed_repo
      title << " (was #{previous_version})" if has_changed_version && !has_changed_repo
      title << " (source changed to `#{current_repo}` from `#{previous_spec_repo}`)" if !has_changed_version && has_changed_repo
      title
    end

    def pods_to_install_include_added_title spec
      title = "Installing #{spec}"
    end

    def pods_to_install_exclude_download spec,thread_index
      UI.section("#{thread_index}:Using #{spec}", title_options[:verbose_prefix]) do
        create_pod_installer(spec.name)
      end
    end

    def create_pod_installer(pod_name)
      specs_by_platform = specs_for_pod(pod_name)

      if specs_by_platform.empty?
        requiring_targets = pod_targets.select { |pt| pt.recursive_dependent_targets.any? { |dt| dt.pod_name == pod_name } }
        message = "Could not install '#{pod_name}' pod"
        message += ", dependended upon by #{requiring_targets.to_sentence}" unless requiring_targets.empty?
        message += '. There is either no platform to build for, or no target to build.'
        raise StandardError, message
      end

      pod_installer = PodSourceInstaller.new(sandbox, podfile, specs_by_platform, :can_cache => installation_options.clean?)
      @mutex.synchronize {
        pod_installers << pod_installer
      }
      pod_installer
    end

    def install_source_of_pod(pod_name)
      pod_installer = create_pod_installer(pod_name)
      pod_installer.install!
      @mutex.synchronize {
        @installed_specs.concat(pod_installer.specs_by_platform.values.flatten.uniq)
      }
    end

    include TimeProfiler::Mixin
    alias origin_prepare prepare

    def prepare
      time_profiler.add_milestone_start time_profiler.stage_prepare, time_profiler.default_step
      origin_prepare
      time_profiler.add_milestone_stop time_profiler.stage_prepare, time_profiler.default_step
    end

    alias origin_run_source_provider_hooks run_source_provider_hooks
    def run_source_provider_hooks
      time_profiler.add_milestone_start time_profiler.stage_resolve_dependencies, "run_source_provider_hooks"
      result=origin_run_source_provider_hooks
      time_profiler.add_milestone_stop time_profiler.stage_resolve_dependencies, "run_source_provider_hooks"
      result
    end

    alias origin_create_analyzer create_analyzer
    def create_analyzer(plugin_sources)
      time_profiler.add_milestone_start time_profiler.stage_resolve_dependencies, "create_analyzer"
      result=origin_create_analyzer(plugin_sources)
      time_profiler.add_milestone_stop time_profiler.stage_resolve_dependencies, "create_analyzer"
      result
    end

    class Analyzer
      alias origin_update_repositories update_repositories
      def update_repositories
        time_profiler.add_milestone_start time_profiler.stage_resolve_dependencies, "update_repositories"
        result=origin_update_repositories
        time_profiler.add_milestone_stop time_profiler.stage_resolve_dependencies, "update_repositories"
        result
      end
    end

    alias origin_analyze analyze
    def analyze(analyzer)
      time_profiler.add_milestone_start time_profiler.stage_resolve_dependencies, "analyze"
      result=origin_analyze(analyzer)
      time_profiler.add_milestone_stop time_profiler.stage_resolve_dependencies, "analyze"
      result
    end

    alias origin_validate_build_configurations validate_build_configurations
    def validate_build_configurations
      time_profiler.add_milestone_start time_profiler.stage_resolve_dependencies, time_profiler.default_step
      result=origin_validate_build_configurations
      time_profiler.add_milestone_stop time_profiler.stage_resolve_dependencies, time_profiler.default_step
      result
    end

    alias origin_verify_no_podfile_changes! verify_no_podfile_changes!
    def verify_no_podfile_changes!
      time_profiler.add_milestone_start time_profiler.stage_resolve_dependencies, "verify_no_podfile_changes!"
      result=origin_verify_no_podfile_changes!
      time_profiler.add_milestone_stop time_profiler.stage_resolve_dependencies, "verify_no_podfile_changes!"
      result
    end

    alias origin_verify_no_lockfile_changes! verify_no_lockfile_changes!
    def verify_no_lockfile_changes!
      time_profiler.add_milestone_start time_profiler.stage_resolve_dependencies, "verify_no_lockfile_changes!"
      result=origin_verify_no_lockfile_changes!
      time_profiler.add_milestone_stop time_profiler.stage_resolve_dependencies, "verify_no_lockfile_changes!"
      result
    end

    alias origin_resolve_dependencies resolve_dependencies
    def resolve_dependencies
      time_profiler.add_milestone_start time_profiler.stage_resolve_dependencies, time_profiler.default_step
      analyzer = origin_resolve_dependencies

      time_profiler.add_milestone_stop time_profiler.stage_resolve_dependencies, time_profiler.default_step

      analyzer
    end

    alias origin_install_pod_sources install_pod_sources
    def install_pod_sources
      time_profiler.add_milestone_start time_profiler.stage_download_dependencies, "install_pod_sources"
      result=origin_install_pod_sources
      time_profiler.add_milestone_stop time_profiler.stage_download_dependencies, "install_pod_sources"
      result
    end

    alias origin_run_podfile_pre_install_hooks run_podfile_pre_install_hooks
    def run_podfile_pre_install_hooks
      time_profiler.add_milestone_start time_profiler.stage_download_dependencies, "run_podfile_pre_install_hooks"
      result=origin_run_podfile_pre_install_hooks
      time_profiler.add_milestone_stop time_profiler.stage_download_dependencies, "run_podfile_pre_install_hooks"
      result
    end

    alias origin_clean_pod_sources clean_pod_sources
    def clean_pod_sources
      time_profiler.add_milestone_start time_profiler.stage_download_dependencies, "clean_pod_sources"
      result=origin_clean_pod_sources
      time_profiler.add_milestone_stop time_profiler.stage_download_dependencies, "clean_pod_sources"
      result
    end

    alias origin_download_dependencies download_dependencies
    def download_dependencies
      time_profiler.add_milestone_start time_profiler.stage_download_dependencies, time_profiler.default_step
      UI.section 'Downloading dependencies' do
        install_pod_sources
        run_podfile_pre_install_hooks
        clean_pod_sources
      end
      time_profiler.add_milestone_stop time_profiler.stage_download_dependencies, time_profiler.default_step
    end

    alias origin_validate_targets validate_targets
    def validate_targets
      time_profiler.add_milestone_start time_profiler.stage_validate_targets, time_profiler.default_step
      result=origin_validate_targets
      result
      time_profiler.add_milestone_stop time_profiler.stage_validate_targets, time_profiler.default_step
    end

    alias origin_show_skip_pods_project_generation_message show_skip_pods_project_generation_message
    def show_skip_pods_project_generation_message
      time_profiler.add_milestone_start time_profiler.stage_show_skip_pods_project_generation_message, time_profiler.default_step
      result=origin_show_skip_pods_project_generation_message
      time_profiler.add_milestone_stop time_profiler.stage_show_skip_pods_project_generation_message, time_profiler.default_step
      result
    end

    alias origin_generate_pods_project generate_pods_project
    def generate_pods_project
      time_profiler.add_milestone_start time_profiler.stage_integrate, "generate_pods_project"
      result=origin_generate_pods_project
      time_profiler.add_milestone_stop time_profiler.stage_integrate, "generate_pods_project"
      result
    end

    alias origin_integrate_user_project integrate_user_project
    def integrate_user_project
      time_profiler.add_milestone_start time_profiler.stage_integrate, "integrate_user_project"
      result=origin_integrate_user_project
      time_profiler.add_milestone_stop time_profiler.stage_integrate, "integrate_user_project"
      result
    end

    alias origin_integrate integrate
    def integrate
      time_profiler.add_milestone_start time_profiler.stage_integrate, time_profiler.default_step
      generate_pods_project
      if installation_options.integrate_targets?
        integrate_user_project
      else
        UI.section 'Skipping User Project Integration'
      end
      time_profiler.add_milestone_stop time_profiler.stage_integrate, time_profiler.default_step
    end

    alias origin_write_lockfiles write_lockfiles
    def write_lockfiles
      time_profiler.add_milestone_start time_profiler.stage_write_lockfiles, time_profiler.default_step
      result=origin_write_lockfiles
      time_profiler.add_milestone_stop time_profiler.stage_write_lockfiles, time_profiler.default_step
      result
    end

    alias origin_run_plugins_post_install_hooks run_plugins_post_install_hooks
    def run_plugins_post_install_hooks
      time_profiler.add_milestone_start time_profiler.stage_perform_post_install_actions, time_profiler.default_step
      result=origin_run_plugins_post_install_hooks
      time_profiler.add_milestone_stop time_profiler.stage_perform_post_install_actions, time_profiler.default_step
      result
    end

    alias :origin_install! :install!
    def install!
      time_profiler.add_milestone_start time_profiler.total_stage, time_profiler.default_step
      rs = origin_install!
      time_profiler.add_milestone_stop time_profiler.total_stage, time_profiler.default_step
      puts time_profiler.format_prints.join("\n")
      rs
    end
  end
end