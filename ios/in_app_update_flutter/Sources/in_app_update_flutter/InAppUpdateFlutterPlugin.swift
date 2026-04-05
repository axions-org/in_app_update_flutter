import UIKit
import Flutter
import StoreKit

public class InAppUpdateFlutterPlugin: NSObject, FlutterPlugin, SKStoreProductViewControllerDelegate {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "in_app_update_flutter", binaryMessenger: registrar.messenger())
    let instance = InAppUpdateFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "showStoreUpdateIosByAppStoreId", "showStoreUpdateIos":
      guard let args = call.arguments as? [String: Any],
            let appStoreId = args["appStoreId"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "appStoreId is required", details: nil))
        return
      }
      showStoreProductView(appStoreId: appStoreId, result: result)

    case "showStoreUpdateIosByBundleId":
      guard let args = call.arguments as? [String: Any],
            let bundleId = args["bundleId"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "bundleId is required", details: nil))
        return
      }
      resolveAppStoreId(bundleId: bundleId, result: result)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func resolveAppStoreId(bundleId: String, result: @escaping FlutterResult) {
    guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid bundle ID", details: nil))
      return
    }

    let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
      DispatchQueue.main.async {
        guard let self = self else { return }

        if let error = error {
          result(FlutterError(
            code: "NETWORK_ERROR",
            message: "Failed to reach iTunes lookup API",
            details: error.localizedDescription
          ))
          return
        }

        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              !results.isEmpty,
              let trackId = results[0]["trackId"] as? Int else {
          let resultCount = (try? JSONSerialization.jsonObject(with: data ?? Data()) as? [String: Any])?["resultCount"] as? Int ?? 0
          if resultCount == 0 {
            result(FlutterError(
              code: "BUNDLE_ID_NOT_FOUND",
              message: "No app found for bundle ID: \(bundleId)",
              details: nil
            ))
          } else {
            result(FlutterError(
              code: "INVALID_RESPONSE",
              message: "Unexpected response from iTunes lookup API",
              details: nil
            ))
          }
          return
        }

        self.showStoreProductView(appStoreId: String(trackId), result: result)
      }
    }
    task.resume()
  }

  private func showStoreProductView(appStoreId: String, result: @escaping FlutterResult) {
    guard let vc = topViewController() else {
      result(FlutterError(code: "STORE_NOT_LOADED", message: "Could not find a view controller to present from", details: nil))
      return
    }

    let productViewController = SKStoreProductViewController()
    productViewController.delegate = self

    let parameters = [SKStoreProductParameterITunesItemIdentifier: appStoreId]

    productViewController.loadProduct(withParameters: parameters) { [weak self] loaded, error in
      DispatchQueue.main.async {
        guard self != nil else { return }

        if let error = error {
          result(FlutterError(code: "STORE_ERROR", message: "Failed to load product", details: error.localizedDescription))
          return
        }

        if loaded {
          vc.present(productViewController, animated: true) {
            result(nil)
          }
        } else {
          result(FlutterError(code: "STORE_NOT_LOADED", message: "Could not load product", details: nil))
        }
      }
    }
  }

  /// Walks the view controller hierarchy to find the topmost presented controller,
  /// which is the correct one to present from at call time.
  private func topViewController() -> UIViewController? {
    guard var top = UIApplication.shared.delegate?.window??.rootViewController else {
      return nil
    }
    while let presented = top.presentedViewController {
      top = presented
    }
    return top
  }

  public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
    viewController.dismiss(animated: true, completion: nil)
  }
}
