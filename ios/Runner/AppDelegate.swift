import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // iCloud 同期と JSON の書き出しは pub のプラグインではなく自前の
    // MethodChannel なので個別に登録する。
    let messenger = engineBridge.applicationRegistrar.messenger()
    IcloudFileStorePlugin.register(with: messenger)
    DocumentExportPlugin.register(with: messenger)
  }
}
