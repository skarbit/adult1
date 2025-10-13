import Foundation
import WebKit
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class HealthMediaHandler: NSObject, WKUIDelegate {
    
    private func presentPicker(_ imagePickerController: UIImagePickerController) {
        presentController(imagePickerController, fallback: {})
    }
    
    private func presentController(_ viewController: UIViewController, fallback: @escaping () -> Void) {
        if #available(iOS 15.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                
                if let alertController = viewController as? UIAlertController,
                   let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = rootViewController.view
                    popoverController.sourceRect = CGRect(x: rootViewController.view.bounds.midX, 
                                                          y: rootViewController.view.bounds.midY, 
                                                          width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                rootViewController.present(viewController, animated: true)
            } else {
                fallback()
            }
        } else {
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                if let alertController = viewController as? UIAlertController,
                   let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = rootViewController.view
                    popoverController.sourceRect = CGRect(x: rootViewController.view.bounds.midX, 
                                                          y: rootViewController.view.bounds.midY, 
                                                          width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                rootViewController.present(viewController, animated: true)
            } else {
                fallback()
            }
        }
    }
}

class HealthAssetDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let completionHandler: ([URL]?) -> Void
    
    init(completionHandler: @escaping ([URL]?) -> Void) {
        self.completionHandler = completionHandler
        super.init()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            
            let temporaryDirectory = FileManager.default.temporaryDirectory
            let fileName = "health_content_asset_\(UUID().uuidString).jpg"
            let fileReference = temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                try imageData.write(to: fileReference)
                completionHandler([fileReference])
            } catch {
                print("Error saving health content asset: \(error.localizedDescription)")
                completionHandler(nil)
            }
        } else {
            completionHandler(nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        completionHandler(nil)
    }
}

