//
//  PhotoLibrarySaver.swift
//  WeeklySchedule
//
//  Saves a received homework photo straight into the user's system Photos library,
//  using the "add-only" permission so we never need broad photo library access.
//

#if os(iOS)
import UIKit
import Photos

enum PhotoLibrarySaver {
    static func save(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else { return }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
}
#endif
