//
//  PlatformImage.swift
//  WeeklySchedule
//

import SwiftUI

#if os(iOS) || os(visionOS)
import UIKit
typealias PlatformImage = UIImage
#else
import AppKit
typealias PlatformImage = NSImage
#endif

extension PlatformImage {
    /// JPEG-encodes the image, downscaling first so saved homework photos stay small on disk.
    func jpegDataCompatible(quality: CGFloat, maxDimension: CGFloat = 1600) -> Data? {
        let scaled = resizedIfNeeded(maxDimension: maxDimension)
        #if os(iOS) || os(visionOS)
        return scaled.jpegData(compressionQuality: quality)
        #else
        guard let tiff = scaled.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .jpeg, properties: [.compressionFactor: quality])
        #endif
    }

    private func resizedIfNeeded(maxDimension: CGFloat) -> PlatformImage {
        #if os(iOS) || os(visionOS)
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension else { return self }
        let scale = maxDimension / longestSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in self.draw(in: CGRect(origin: .zero, size: newSize)) }
        #else
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension else { return self }
        let scale = maxDimension / longestSide
        let newSize = NSSize(width: size.width * scale, height: size.height * scale)
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        draw(in: NSRect(origin: .zero, size: newSize), from: .zero, operation: .copy, fraction: 1)
        newImage.unlockFocus()
        return newImage
        #endif
    }
}

extension Image {
    init(platformImage: PlatformImage) {
        #if os(iOS) || os(visionOS)
        self.init(uiImage: platformImage)
        #else
        self.init(nsImage: platformImage)
        #endif
    }
}
