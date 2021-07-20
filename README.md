# cocoapods-pdk8
> 因为精力有限，目前只兼容了`cocoapods 1.10.0`，如有其他版本的需求，可以提`issue`给我，在时间允许的情况下我会兼容的
`pdk8`的取名来自于保时捷`pdk`8速变速箱，也是我这边的期望，我们这个小工具可以让`pod install/update`的速度可以跟保时捷的跑车一样快。

## Feature
- 减少文件IO和优化获取算法
- 多线程加载`Pods`
## Installation

    $ gem install cocoapods-pdk8

## Usage

`Podfile`里面如果有的多个`source`,如果定义`force`,会优先匹配`force`的源,如果只有一个`source`就不需要关心这个
```
    force_source 'source2'
    source 'source1'
```

然后就按照普通的`pod install/update`即可，就可以享受到加速,命令行看到`pkd8 enable`即享受到了加速
```
pdk8 enable
Analyzing dependencies
Downloading dependencies
finish xxx cost: 0s
finish xxx cost: 0s
finish xxx cost: 0s
finish xxx cost: 0s
finish xxx cost: 0s
finish xxx cost: 0s
finish xxx cost: 0s
finish xxx cost: 0s
finish xxx cost: 0s
Generating Pods project
Integrating client project
Pod installation complete! There is 1 dependency from the Podfile and 14 total pods installed.
- total: 1s
-- prepare: 0s
-- resolve_dependencies: 0s
--- run_source_provider_hooks: 0s
--- create_analyzer: 0s
--- analyze: 1s
-- download_dependencies: 0s
--- install_pod_sources: 0s
--- run_podfile_pre_install_hooks: 0s
--- clean_pod_sources: 0s
-- validate_targets: 0s
-- integrate: 0s
--- generate_pods_project: 0s
--- integrate_user_project: 0s
-- write_lockfiles: 0s
-- perform_post_install_actions: 0s
```
不想享受加速直接卸载即可

```
gem uninstall cocoapods-pdk8
```