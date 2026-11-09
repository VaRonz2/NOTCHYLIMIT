import SwiftUI

/// Slim single-line header: sync status — settings gear.
struct HeaderRow: View {
    @ObservedObject var appState: AppState
    let controller: NotchWindowController

    var body: some View {
        HStack(spacing: 6) {
            Text(syncSubtitle)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(Theme.textSecondary)
                .lineLimit(1)

            Spacer()

            Button { appState.showSettings = true } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary.opacity(0.85))
            }
            .buttonStyle(.borderless)
            .help("Settings")
        }
    }

    private var syncSubtitle: String {
        switch appState.syncStatus {
        case .idle:           return "Idle"
        case .syncing:        return "Syncing…"
        case .ok(let at):     return "Updated \(relative(at))"
        case .error(let e):   return e.description
        }
    }

    private func relative(_ date: Date) -> String {
        let secs = Int(Date().timeIntervalSince(date))
        if secs < 60    { return "just now" }
        if secs < 3600  { return "\(secs / 60)m ago" }
        if secs < 86400 { return "\(secs / 3600)h ago" }
        return "\(secs / 86400)d ago"
    }
}
