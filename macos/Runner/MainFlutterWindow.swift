import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // 设置窗口大小
    self.setContentSize(NSSize(width: 850, height: 750))

    // 设置窗口禁止缩放
    // let window: NSWindow! = self.contentView?.window
    // window.styleMask.remove(.resizable)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
