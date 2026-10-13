import AppKit
import Foundation

final class BoostController {
    private let primer = EDRPrimer()
    private let split = SplitOverlay()
    private let power = PowerMonitor()
    private var wakeObserver: NSObjectProtocol?
    private var screenObserver: NSObjectProtocol?
    private var watchdog: Timer?

    var onStateChange: (() -> Void)?

    enum Mode: String {
        case off
        case freeHalf
        case full
        case unsupported
        case waitingForAC
    }

    private(set) var mode: Mode = .off

    func start() {
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
        defer { onStateChange?() }

        guard DisplaySupport.hasSupportedDisplay else {
            applyOff()
            mode = .unsupported
            return
        }

        guard Settings.enabled else {
            applyOff()
            mode = .off
            return
        }

        if Settings.acOnly && !power.isOnACPower {
            applyOff()
            mode = .waitingForAC
            return
        }

        let screens = DisplaySupport.builtInEDRScreens
        let ceiling = Settings.boostCeiling

        if Settings.isLicensed {
            split.hide()
            primer.enable(for: screens)
            for screen in screens {
                if let id = DisplaySupport.displayID(for: screen) {
                    GammaBoost.apply(displayID: id, ceiling: ceiling)
                }
            }
            if forceRefresh {
                primer.refreshAll()
            }
            mode = .full
        } else {
            GammaBoost.restore()
            primer.disable()
            if let screen = screens.first {
                split.show(on: screen, factor: ceiling, side: Settings.freeHalfSide)
            }
            mode = .freeHalf
        }
    }

    private func applyOff() {
        split.hide()
        primer.disable()
        GammaBoost.restore()
    }
}
