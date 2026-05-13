import SwiftUI

// 这是 demo 的应用入口。
@main
struct MainActorUIStateDemoApp: App {
  // 用 StateObject 持有 1 份主线程 UI 状态对象。
  @StateObject private var board = MainActorStatusBoard()

  // 定义主窗口。
  var body: some Scene {
    // 用单窗口承载 demo。
    Window("MainActor Demo", id: "main") {
      // 把状态对象传给内容视图。
      ContentView(board: board)
    }
    // 给窗口 1 个舒服尺寸。
    .defaultSize(width: 1180, height: 820)
  }
}
