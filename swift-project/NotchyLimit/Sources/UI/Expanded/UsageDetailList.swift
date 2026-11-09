import SwiftUI

/// Detailed usage rows for the currently selected provider.
struct UsageDetailList: View {
    @ObservedObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let incident = appState.activeIncident {
                IncidentBanner(providerName: appState.activeProviderId.displayName,
                               incident: incident)
            }

            if let snapshot = appState.latestSnapshot {
                if snapshot.isBalance {
                    Text("Credit remaining: \(snapshot.shortLabel)")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                } else if snapshot.isStatusOnly {
                    Text("Connected — this provider doesn't report a usage %")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                } else {
                    row(title: "Session", window: snapshot.primaryWindow)
                    if let secondary = snapshot.secondaryWindow {
                        row(title: "Weekly", window: secondary)
                    }
                    if let tertiary = snapshot.tertiaryWindow {
                        row(title: "Weekly Sonnet", window: tertiary)
                    }
                }
            } else if let error = appState.providerErrors[appState.activeProviderId] {
                Text(error.description)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
            } else {
                Text("Not connected — set it up in Settings")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
            }
        }
    }

    @ViewBuilder
    private func row(title: String, window: UsageWindow) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                Text("\(Int((window.percentUsed * 100).rounded()))%")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(window.status.color)
                Spacer(minLength: 0)
                if let reset = window.timeToResetString() {
                    Text(reset)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(1)
                }
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(window.status.color)
                        .frame(width: geometry.size.width * min(max(window.percentUsed, 0), 1))
                }
            }
            .frame(height: 4)
        }
    }
}
