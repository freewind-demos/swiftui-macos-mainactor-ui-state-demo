import SwiftUI

// 这是主界面。
struct ContentView: View {
  // 直接观察主 actor 状态板。
  @ObservedObject var board: MainActorStatusBoard

  // 组织整体布局。
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      headerCard

      HStack(alignment: .top, spacing: 16) {
        actionPanel
        logPanel
      }
    }
    .padding(20)
    .frame(minWidth: 1100, minHeight: 760)
  }

  // 顶部说明卡。
  private var headerCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("@MainActor = UI 状态统一回主线程写")
        .font(.system(size: 28, weight: .bold))

      Text("按钮会从后台 Task.detached 发起任务。真正写 board.status / board.logs 时，会 await 回 @MainActor 对象。")
        .foregroundStyle(.secondary)

      HStack(spacing: 10) {
        badge("后台产结果")
        badge("主 actor 落 UI")
        badge("日志直接显示线程")
      }
    }
    .padding(18)
    .background(.thinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }

  // 左边操作区。
  private var actionPanel: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("操作区")
        .font(.headline)

      stateRow(name: "status", value: board.status)
      stateRow(name: "isLoading", value: "\(board.isLoading)")

      Button(board.isLoading ? "后台任务进行中..." : "启动后台任务") {
        // 如果已经在加载，就不重复触发。
        guard !board.isLoading else {
          return
        }

        // 先在主 actor 上更新 UI。
        board.begin()

        // 再故意去后台跑任务。
        Task.detached {
          // 模拟后台等待。
          try? await Task.sleep(for: .milliseconds(900))

          // 先记录后台线程信息。
          let backgroundMessage = "detached task 主线程=\(Thread.isMainThread)"

          // 再把结果交回主 actor。
          await board.finish(backgroundMessage: backgroundMessage)
        }
      }

      Button("重置") {
        board.reset()
      }

      insightCard(
        title: "观察点",
        body: "先看 detached task 那条日志，再看 finish() 那条日志。前者通常是 false，后者应是 true。"
      )

      Spacer(minLength: 0)
    }
    .padding(18)
    .frame(width: 360)
    .frame(minHeight: 360, alignment: .topLeading)
    .background(.regularMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }

  // 右边日志区。
  private var logPanel: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("日志墙")
        .font(.headline)

      insightCard(
        title: "本质",
        body: "@MainActor 不是帮你做后台任务，而是规定：这个对象上的状态写入必须回主 actor。"
      )

      ScrollView {
        LazyVStack(alignment: .leading, spacing: 10) {
          ForEach(Array(board.logs.enumerated()), id: \.offset) { _, line in
            Text(line)
              .font(.system(.body, design: .monospaced))
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(12)
              .background(Color.primary.opacity(0.04))
              .clipShape(RoundedRectangle(cornerRadius: 10))
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .padding(18)
    .frame(maxWidth: .infinity, minHeight: 360, alignment: .topLeading)
    .background(.regularMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }

  // 构造状态行。
  private func stateRow(name: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(name)
        .font(.caption)
        .foregroundStyle(.secondary)

      Text(value)
        .font(.system(.body, design: .monospaced))
        .textSelection(.enabled)
    }
  }

  // 构造说明卡片。
  private func insightCard(title: String, body: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.headline)

      Text(body)
        .foregroundStyle(.secondary)
    }
    .padding(14)
    .background(Color.primary.opacity(0.04))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  // 顶部小标签。
  private func badge(_ text: String) -> some View {
    Text(text)
      .font(.caption.weight(.medium))
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .background(Color.primary.opacity(0.06))
      .clipShape(Capsule())
  }
}
