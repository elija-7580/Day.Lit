import SwiftUI

struct ContentView: View {
    @ObservedObject var boost: BoostController

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.35)
            controls
            Spacer(minLength: 0)
            footer
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, 20)
        .frame(width: 380, height: 420)
        .background(WindowBackground())
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(nsImage: appIconImage)
                .resizable()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .black.opacity(0.18), radius: 8, y: 3)

            VStack(alignment: .leading, spacing: 4) {
                Text("Day.Lit")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                Text(boost.statusText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(statusColor)
            }
            Spacer()
            Toggle("", isOn: $boost.enabled)
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.large)
        }
        .padding(.bottom, 18)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Brightness")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1f×", boost.boostCeiling))
                        .font(.system(size: 15, weight: .semibold, design: .rounded).monospacedDigit())
                }

                Slider(
                    value: Binding(
                        get: { Double(boost.boostCeiling) },
                        set: { boost.boostCeiling = Float($0) }
                    ),
                    in: 1.0...2.0,
                    step: 0.05
                )
                .controlSize(.large)
                .disabled(!boost.enabled || boost.mode == .unsupported)

                HStack {
                    Text("Stock")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Text("Max")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(16)
            .background(cardBackground)

            VStack(spacing: 0) {
                settingsRow(title: "Only on power adapter", subtitle: "Saves battery outdoors") {
                    Toggle("", isOn: $boost.acOnly)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
                Divider().padding(.leading, 14)
                settingsRow(title: "Open at login", subtitle: "Start with your Mac") {
                    Toggle("", isOn: $boost.launchAtLogin)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
            }
            .background(cardBackground)
        }
        .padding(.top, 18)
    }

    private var footer: some View {
        HStack {
            Text("Free forever")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiary)
            Spacer()
            Button("Quit") {
                boost.stop()
                NSApp.terminate(nil)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            .controlSize(.small)
        }
        .padding(.top, 16)
    }

    private func settingsRow<Trailing: View>(
        title: String,
        subtitle: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13, weight: .medium))
                Text(subtitle).font(.system(size: 11)).foregroundStyle(.secondary)
            }
            Spacer()
            trailing()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var statusColor: Color {
        switch boost.mode {
        case .on: return Color(red: 0.95, green: 0.62, blue: 0.18)
        case .off: return .secondary
        case .waitingForAC: return .orange
        case .unsupported: return .red.opacity(0.85)
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(.white.opacity(0.12), lineWidth: 0.5)
            )
    }

    private var appIconImage: NSImage {
        if let url = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
           let image = NSImage(contentsOf: url) {
            return image
        }
        return NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: nil) ?? NSImage()
    }
}

private struct WindowBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(nsColor: .windowBackgroundColor),
                Color(red: 0.12, green: 0.10, blue: 0.08).opacity(0.35)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
