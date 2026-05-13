# SwiftUI macOS MainActor UI State Demo

## 简介

这是 1 个只讲 `@MainActor` 的 macOS SwiftUI demo。

它会故意从后台 `Task.detached` 里产出结果，再 `await` 回 `@MainActor` 标注的 view model，直接把“后台产生，主线程落 UI”这件事摊开给你看。

## 快速开始

### 环境要求

- macOS 14+
- Xcode 15+
- XcodeGen

### 运行

```bash
cd /Users/peng.li/workspace/freewind-demos/swiftui-macos-mainactor-ui-state-demo
./scripts/build.sh
open MainActorUIStateDemo.xcodeproj
```

### 开发循环

```bash
cd /Users/peng.li/workspace/freewind-demos/swiftui-macos-mainactor-ui-state-demo
./dev.sh
```

## 注意事项

- 这个 demo 的重点不是多线程性能
- 重点是“UI 状态改动统一收口到主 actor”
- 日志里会明确显示后台线程与主线程

## 教程

### 1. `@MainActor` 在解决什么

SwiftUI 界面状态最好只在主线程改。

如果后台任务完成后随便乱写 UI 状态：

- 容易线程不安全
- 更新路径会散

`@MainActor` 的意思就是：

- 这个对象归主 actor 管
- 谁想改它，都得切回主 actor

### 2. 生动例子

把它想成前台屏幕控制台：

- 后台同事去仓库找资料
- 找到后不能自己冲到前台屏幕乱写
- 必须把结果交回前台值班员
- 值班员再把字打到屏幕上

这里的“前台值班员”，就是 `@MainActor`。

## 操作

1. 点“启动后台任务”
2. 看日志先出现后台线程记录
3. 再看日志出现“进入 @MainActor 方法时主线程=true”
4. 连点几次，体会所有 UI 状态都统一回主线程写
