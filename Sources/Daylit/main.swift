import AppKit

let app = NSApplication.shared
// Menu-bar agent by default (Scratchpad-style). Dock can be enabled in the panel.
app.setActivationPolicy(Settings.showDockIcon ? .regular : .accessory)

let delegate = AppDelegate()
app.delegate = delegate
app.run()
