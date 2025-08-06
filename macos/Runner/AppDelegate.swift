import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {

    if let window = NSApplication.shared.windows.first {
        window.title = "Layerbase"

        // Set icon in title bar
        let imageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 18, height: 18))
        imageView.image = NSImage(named: "Icon")
        imageView.imageScaling = .scaleProportionallyUpOrDown

        window.standardWindowButton(.closeButton)?.superview?.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: window.standardWindowButton(.closeButton)!.superview!.leadingAnchor, constant: 6).isActive = true
        imageView.centerYAnchor.constraint(equalTo: window.contentView!.topAnchor, constant: -10).isActive = true
    }
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
