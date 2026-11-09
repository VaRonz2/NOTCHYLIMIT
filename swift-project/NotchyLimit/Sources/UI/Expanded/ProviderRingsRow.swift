import SwiftUI
import AppKit

/// Compact provider switcher using one small status ring per enabled provider.
struct ProviderRingsRow: View {
    @ObservedObject var appState: AppState

    var body: some View {
        Group {
            if appState.enabledProviders.count > 4 {
                ScrollView(.horizontal, showsIndicators: false) {
                    rings
                }
            } else {
                rings
            }
        }
    }

    private var rings: some View {
        HStack(alignment: .top, spacing: 14) {
            ForEach(appState.enabledProviders, id: \.self) { pid in
                provider(pid)
            }
            Spacer(minLength: 0)
        }
    }

    private func provider(_ pid: ProviderId) -> some View {
        let snapshot = appState.snapshots[pid]
        let isActive = pid == appState.activeProviderId
        let progress: Double
        let color: Color

        if let snapshot {
            if snapshot.showsPercentBar {
                progress = min(max(snapshot.primaryWindow.percentUsed, 0), 1)
                color = snapshot.combinedStatus.color
            } else if snapshot.isBalance {
                progress = 0
                color = Theme.statusHealthy
            } else {
                progress = 1
                color = Theme.statusHealthy.opacity(0.5)
            }
        } else {
            progress = 0
            color = Theme.textSecondary
        }

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                appState.activeProviderId = pid
                appState.latestSnapshot = appState.snapshots[pid]
            }
        } label: {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    StatusRingView(progress: progress, color: color, size: 44)
                    ProviderIconView(id: pid, size: 16, fallbackColor: .white.opacity(0.85))
                    if let incident = appState.incidents[pid], incident.level.isActive {
                        Image(systemName: incident.level.glyph)
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(incident.level.tint)
                            .offset(x: 3, y: -3)
                    }
                }
                Text(snapshot?.shortLabel ?? "—")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(pid.displayName)
                    .font(.system(size: 9, design: .rounded))
                    .foregroundColor(isActive ? Theme.textPrimary : Theme.textSecondary)
                    .lineLimit(1)
                Circle()
                    .fill(Theme.accentWarm)
                    .frame(width: 3, height: 3)
                    .opacity(isActive ? 1 : 0)
            }
            .frame(width: 64)
            .opacity(isActive ? 1 : 0.55)
        }
        .buttonStyle(.plain)
        .contextMenu {
            if let url = pid.dashboardURL {
                Button("Open \(pid.displayName) dashboard") { NSWorkspace.shared.open(url) }
            }
        }
    }
}
