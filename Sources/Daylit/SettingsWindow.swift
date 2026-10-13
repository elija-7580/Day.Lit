import AppKit

final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    private let boost: BoostController
    private var intensityLabel: NSTextField!
    private var licenseField: NSTextField!
    private var statusLabel: NSTextField!
    private var licenseStatus: NSTextField!
    private var onChange: (() -> Void)?

    init(boost: BoostController, onChange: (() -> Void)? = nil) {
        self.boost = boost
        self.onChange = onChange

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 390),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Daylit Settings"
        window.isReleasedWhenClosed = false
        window.center()

        super.init(window: window)
        window.delegate = self
        window.contentView = buildContent()
        refresh()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func show() {
        LaunchAtLogin.syncFromSystem()
        refresh()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func buildContent() -> NSView {
        let root = NSView(frame: NSRect(x: 0, y: 0, width: 420, height: 390))

        var y = 340.0
        let pad: CGFloat = 24

        statusLabel = makeLabel("", bold: true)
        statusLabel.frame = NSRect(x: pad, y: y, width: 372, height: 20)
        root.addSubview(statusLabel)
        y -= 36

        let boostTitle = makeLabel("Boost", bold: true)
        boostTitle.frame = NSRect(x: pad, y: y, width: 200, height: 18)
        root.addSubview(boostTitle)
        y -= 28

        let enable = NSButton(checkboxWithTitle: "Enable Daylit", target: self, action: #selector(toggleEnabled(_:)))
        enable.tag = 1
        enable.frame = NSRect(x: pad, y: y, width: 280, height: 20)
        enable.state = Settings.enabled ? .on : .off
        root.addSubview(enable)
        y -= 28

        intensityLabel = makeLabel(String(format: "Intensity  %.1f×", Settings.boostCeiling), bold: false)
        intensityLabel.frame = NSRect(x: pad, y: y, width: 200, height: 18)
        root.addSubview(intensityLabel)
        y -= 28

        let slider = NSSlider(value: Double(Settings.boostCeiling), minValue: 1.0, maxValue: 2.0, target: self, action: #selector(sliderChanged(_:)))
        slider.isContinuous = true
        slider.frame = NSRect(x: pad, y: y, width: 372, height: 24)
        root.addSubview(slider)
        y -= 36

        let powerTitle = makeLabel("Power & startup", bold: true)
        powerTitle.frame = NSRect(x: pad, y: y, width: 240, height: 18)
        root.addSubview(powerTitle)
        y -= 28

        let ac = NSButton(checkboxWithTitle: "Only when on power adapter", target: self, action: #selector(toggleAC(_:)))
        ac.frame = NSRect(x: pad, y: y, width: 320, height: 20)
        ac.state = Settings.acOnly ? .on : .off
        ac.tag = 2
        root.addSubview(ac)
        y -= 26

        let login = NSButton(checkboxWithTitle: "Open at login", target: self, action: #selector(toggleLogin(_:)))
        login.frame = NSRect(x: pad, y: y, width: 280, height: 20)
        login.state = LaunchAtLogin.isEnabled ? .on : .off
        login.tag = 3
        root.addSubview(login)
        y -= 36

        let freeTitle = makeLabel("Free mode", bold: true)
        freeTitle.frame = NSRect(x: pad, y: y, width: 200, height: 18)
        root.addSubview(freeTitle)
        y -= 28

        let side = NSPopUpButton(frame: NSRect(x: pad, y: y, width: 200, height: 24), pullsDown: false)
        side.addItems(withTitles: ["Brighten left half", "Brighten right half"])
        side.selectItem(at: Settings.freeHalfSide == .left ? 0 : 1)
        side.target = self
        side.action = #selector(sideChanged(_:))
        root.addSubview(side)
        y -= 40

        let licenseTitle = makeLabel("License", bold: true)
        licenseTitle.frame = NSRect(x: pad, y: y, width: 200, height: 18)
        root.addSubview(licenseTitle)
        y -= 28

        licenseField = NSTextField(string: Settings.licenseKey)
        licenseField.placeholderString = "DAYLIT-…"
        licenseField.frame = NSRect(x: pad, y: y, width: 260, height: 24)
        root.addSubview(licenseField)

        let apply = NSButton(title: "Apply", target: self, action: #selector(applyLicense))
        apply.bezelStyle = .rounded
        apply.frame = NSRect(x: pad + 270, y: y - 2, width: 80, height: 28)
        root.addSubview(apply)
        y -= 28

        licenseStatus = makeLabel("", bold: false)
        licenseStatus.textColor = .secondaryLabelColor
        licenseStatus.frame = NSRect(x: pad, y: y, width: 372, height: 18)
        root.addSubview(licenseStatus)

        return root
    }

    private func makeLabel(_ text: String, bold: Bool) -> NSTextField {
        let field = NSTextField(labelWithString: text)
        field.font = bold
            ? NSFont.systemFont(ofSize: 13, weight: .semibold)
            : NSFont.systemFont(ofSize: 13)
        return field
    }

    func refresh() {
        intensityLabel?.stringValue = String(format: "Intensity  %.1f×", Settings.boostCeiling)
        licenseField?.stringValue = Settings.licenseKey
        statusLabel?.stringValue = statusLine()
        licenseStatus?.stringValue = Settings.isLicensed
            ? "Full screen unlocked"
            : "Free: half screen until you unlock"
        onChange?()
    }

    private func statusLine() -> String {
        switch boost.mode {
        case .off: return "Status: Off"
        case .freeHalf: return "Status: Free half-screen"
        case .full: return "Status: Full unlock"
        case .unsupported: return "Status: Display has no XDR headroom"
        case .waitingForAC: return "Status: Waiting for power adapter"
        }
    }

    @objc private func toggleEnabled(_ sender: NSButton) {
        Settings.enabled = sender.state == .on
        boost.reconcile()
        refresh()
    }

    @objc private func toggleAC(_ sender: NSButton) {
        Settings.acOnly = sender.state == .on
        boost.reconcile()
        refresh()
    }

    @objc private func toggleLogin(_ sender: NSButton) {
        let ok = LaunchAtLogin.setEnabled(sender.state == .on)
        if !ok {
            sender.state = LaunchAtLogin.isEnabled ? .on : .off
            let alert = NSAlert()
            alert.messageText = "Could not change login item"
            alert.informativeText = "Allow Daylit under System Settings → General → Login Items, then try again."
            alert.runModal()
        }
    }

    @objc private func sliderChanged(_ sender: NSSlider) {
        Settings.boostCeiling = Float(sender.doubleValue)
        boost.reconcile()
        refresh()
    }

    @objc private func sideChanged(_ sender: NSPopUpButton) {
        Settings.freeHalfSide = sender.indexOfSelectedItem == 0 ? .left : .right
        boost.reconcile()
        refresh()
    }

    @objc private func applyLicense() {
        Settings.licenseKey = licenseField.stringValue
        boost.reconcile()
        refresh()
    }
}
