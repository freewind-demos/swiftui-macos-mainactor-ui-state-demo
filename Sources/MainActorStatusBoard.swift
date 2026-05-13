import Foundation
import SwiftUI

// 这是专门放 UI 状态的主 actor 对象。
@MainActor
final class MainActorStatusBoard: ObservableObject {
  // 当前状态文案。
  @Published var status: String

  // 事件日志。
  @Published var logs: [String]

  // 正在加载标记。
  @Published var isLoading: Bool

  // 初始化默认状态。
  init(
    status: String = "等待后台任务",
    logs: [String] = [],
    isLoading: Bool = false
  ) {
    // 保存初始状态。
    self.status = status

    // 保存初始日志。
    self.logs = logs

    // 保存初始 loading 状态。
    self.isLoading = isLoading
  }

  // 开始 1 次后台任务。
  func begin() {
    // 主线程上更新 UI。
    status = "已启动后台任务"

    // 主线程上打开 loading。
    isLoading = true

    // 记 1 条主线程日志。
    logs.insert("begin() 主线程=\(Thread.isMainThread)", at: 0)
  }

  // 接收后台任务结果。
  func finish(backgroundMessage: String) {
    // 在主 actor 上写最终状态。
    status = "已收到后台结果"

    // 在主 actor 上关掉 loading。
    isLoading = false

    // 把后台消息也写进日志。
    logs.insert(backgroundMessage, at: 0)

    // 记录当前方法执行时是否在主线程。
    logs.insert("finish() 进入 @MainActor 后主线程=\(Thread.isMainThread)", at: 0)
  }

  // 清空日志。
  func reset() {
    // 重置文案。
    status = "等待后台任务"

    // 关闭 loading。
    isLoading = false

    // 清空日志。
    logs.removeAll()
  }
}
