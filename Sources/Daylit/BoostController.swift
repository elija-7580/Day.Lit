import AppKit
import Foundation
import Combine

final class BoostController: ObservableObject {
    private let primer = EDRPrimer()
    private let power = PowerMonitor()
    private var wakeObserver: NSObjectProtocol?
    private var screenObserver: NSObjectProtocol?
    private var watchdog: Timer?

    enum Mode: String {
        case off
        case on
        case unsupported
        case waitingForAC
    }

    @Published private(set) var mode: Mode = .off
    @Published var enabled: Bool = Settings.enabled {
        didSet {
            Settings.enabled = enabled
            reconcile()
        }
    }
    @Published var boostCeiling: Float = Settings.boostCeiling {
        didSet {
            Settings.boostCeiling = boostCeiling
            reconcile()
        }
    }
    @Published var acOnly: Bool = Settings.acOnly {
        didSet {
            Settings.acOnly = acOnly
            reconcile()
        }
    }
    @Published var launchAtLogin: Bool = LaunchAtLogin.isEnabled {
        didSet {
            _ = LaunchAtLogin.setEnabled(launchAtLogin)
            launchAtLogin = LaunchAtLogin.isEnabled
        }
    }

    var statusText: String {
        switch mode {
        case .off: return "Off"
        case .on: return "Boosting"
        case .unsupported: return "This display has no XDR headroom"
        case .waitingForAC: return "Waiting for power adapter"
        }
    }

    func start() {
        LaunchAtLogin.syncFromSystem()
        launchAtLogin = LaunchAtLogin.isEnabled
        enabled = Settings.enabled
        boostCeiling = Settings.boostCeiling
        acOnly = Settings.acOnly

        power.onChange = { [weak self] in self?.reconcile() }
        power.start()

        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reconcile(forceRefresh: true)
        }

        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reconcile(forceRefresh: true)
        }

        watchdog = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.reconcile()
        }
        if let watchdog {
            RunLoop.main.add(watchdog, forMode: .common)
        }

        reconcile()
    }

    func stop() {
        if let wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver)
        }
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }
        watchdog?.invalidate()
        power.stop()
        applyOff()
    }

    func reconcile(forceRefresh: Bool = false) {
        guard DisplaySupport.hasSupportedDisplay else {
            applyOff()
            mode = .unsupported
            return
        }

        guard enabled else {
            applyOff()
            mode = .off
            return
        }

        if acOnly && !power.isOnACPower {
            applyOff()
            mode = .waitingForAC
            return
        }

        let screens = DisplaySupport.builtInEDRScreens
        primer.enable(for: screens)
        for screen in screens {
            if let id = DisplaySupport.displayID(for: screen) {
                GammaBoost.apply(displayID: id, ceiling: boostCeiling)
            }
        }
        if forceRefresh {
            primer.refreshAll()
        }
        mode = .on
    }

    private func applyOff() {
        primer.disable()
        GammaBoost.restore()
    }
}
