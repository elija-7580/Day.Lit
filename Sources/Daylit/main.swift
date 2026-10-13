import AppKit

let app = NSApplication.shared
// Menu bar by default. The Dock icon can be enabled in the panel.
app.setActivationPolicy(Settings.showDockIcon ? .regular : .accessory)

let delegate = AppDelegate()
app.delegate = delegate
app.run()
