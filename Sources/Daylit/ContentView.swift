import SwiftUI

struct ContentView: View {
    @ObservedObject var boost: BoostController

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.25)
            controls
            Spacer(minLength: 8)
            footer
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 14)
        .frame(width: 320, height: 368)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color(red: 1.0, green: 0.78, blue: 0.30))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.primary.opacity(0.06))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Day.Lit")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Text(boost.statusText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(statusColor)
            }
            Spacer(minLength: 8)
            Toggle("", isOn: $boost.enabled)
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.small)
        }
        .padding(.bottom, 14)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Brightness")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1f×", boost.boostCeiling))
                        .font(.system(size: 13, weight: .semibold, design: .rounded).monospacedDigit())
                }

                Slider(
                    value: Binding(
                        get: { Double(boost.boostCeiling) },
                        set: { boost.boostCeiling = Float($0) }
                    ),
                    in: 1.0...2.0,
                    step: 0.05
                )
                .disabled(!boost.enabled || boost.mode == .unsupported)

                HStack {
                    Text("Stock")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Text("Max")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(12)
            .background(cardBackground)

            VStack(spacing: 0) {
                settingsRow(title: "Only on power adapter", subtitle: "Saves battery") {
                    Toggle("", isOn: $boost.acOnly)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .controlSize(.small)
                }
                Divider().padding(.leading, 12)
                settingsRow(title: "Open at login", subtitle: "Start with your Mac") {
                    Toggle(
                        "",
                        isOn: Binding(
                            get: { boost.launchAtLogin },
                            set: { boost.setLaunchAtLogin($0) }
                        )
                    )
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .controlSize(.small)
                }
                Divider().padding(.leading, 12)
                settingsRow(title: "Show in Dock", subtitle: "Keep Day.Lit in the Dock") {
                    Toggle(
                        "",
                        isOn: Binding(
                            get: { boost.showDockIcon },
                            set: { boost.setShowDockIcon($0) }
                        )
                    )
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .controlSize(.small)
                }
            }
            .background(cardBackground)
        }
        .padding(.top, 14)
    }

    private var footer: some View {
        HStack {
            Text("Menu bar · free")
                .font(.system(size: 10, weight: .medium))
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
        .padding(.top, 10)
    }

    private func settingsRow<Trailing: View>(
        title: String,
        subtitle: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.system(size: 12, weight: .medium))
                Text(subtitle).font(.system(size: 10)).foregroundStyle(.secondary)
            }
            Spacer()
            trailing()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
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
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.primary.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
            )
    }
}
