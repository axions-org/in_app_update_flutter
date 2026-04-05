import UIKit
import Flutter
import StoreKit

public class InAppUpdateFlutterPlugin: NSObject, FlutterPlugin, SKStoreProductViewControllerDelegate {
  var flutterResult: FlutterResult?
  var controller: UIViewController?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "in_app_update_flutter", binaryMessenger: registrar.messenger())
    let instance = InAppUpdateFlutterPlugin()
    instance.controller = UIApplication.shared.delegate?.window??.rootViewController
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
      flutterResult = result
      showStoreProductView(appStoreId: appStoreId)

    case "showStoreUpdateIosByBundleId":
      guard let args = call.arguments as? [String: Any],
            let bundleId = args["bundleId"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "bundleId is required", details: nil))
        return
      }
      flutterResult = result
      resolveAppStoreId(bundleId: bundleId)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func resolveAppStoreId(bundleId: String) {
    guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else {
      flutterResult?(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid bundle ID", details: nil))
      return
    }

    let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
      DispatchQueue.main.async {
        guard let self = self else { return }

        if let error = error {
          self.flutterResult?(FlutterError(
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
            self.flutterResult?(FlutterError(
              code: "BUNDLE_ID_NOT_FOUND",
              message: "No app found for bundle ID: \(bundleId)",
              details: nil
            ))
          } else {
            self.flutterResult?(FlutterError(
              code: "INVALID_RESPONSE",
              message: "Unexpected response from iTunes lookup API",
              details: nil
            ))
          }
          return
        }

        self.showStoreProductView(appStoreId: String(trackId))
      }
    }
    task.resume()
  }

  private func showStoreProductView(appStoreId: String) {
    let productViewController = SKStoreProductViewController()
    productViewController.delegate = self

    let parameters = [SKStoreProductParameterITunesItemIdentifier : appStoreId]

    productViewController.loadProduct(withParameters: parameters) { loaded, error in
      if let error = error {
        self.flutterResult?(FlutterError(code: "STORE_ERROR", message: "Failed to load product", details: error.localizedDescription))
        return
      }

      if loaded, let vc = self.controller {
        vc.present(productViewController, animated: true) {
          self.flutterResult?(nil)
        }
      } else {
        self.flutterResult?(FlutterError(code: "STORE_NOT_LOADED", message: "Could not load product", details: nil))
      }
    }
  }

  public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
    viewController.dismiss(animated: true, completion: nil)
  }
}
