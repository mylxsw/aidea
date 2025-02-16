import Cocoa
import FlutterMacOS
import bitsdojo_window_macos

class MainFlutterWindow: BitsdojoWindow {
  override func bitsdojo_window_configure() -> UInt {
     return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
  }
  
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
