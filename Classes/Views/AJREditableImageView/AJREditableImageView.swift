//
//  AJREditableImageView.swift
//  AJRInterface
//
//  Created by AJ Raftis on 7/26/26.
//

import Cocoa

@objcMembers
open class AJREditableImageView: NSImageView {

    // MARK: - Actions

    @IBAction
    open func flipVertical(_ sender: Any?) {
        guard let image else {
            return
        }

        let transform = NSAffineTransform()
        transform.transformStruct = NSAffineTransformStruct(
            m11: 1.0,
            m12: 0.0,
            m21: 0.0,
            m22: -1.0,
            tX: 0.0,
            tY: image.size.height
        )

        self.image = transformedImage(from: image, transform: transform)
    }

    @IBAction
    open func flipHorizontal(_ sender: Any?) {
        guard let image else {
            return
        }

        let transform = NSAffineTransform()
        transform.transformStruct = NSAffineTransformStruct(
            m11: -1.0,
            m12: 0.0,
            m21: 0.0,
            m22: 1.0,
            tX: image.size.width,
            tY: 0.0
        )

        self.image = transformedImage(from: image, transform: transform)
    }

    @IBAction
    open func rotateLeft(_ sender: Any?) {
        guard let image else {
            return
        }

        let transform = NSAffineTransform()
        transform.transformStruct = NSAffineTransformStruct(
            m11: 0.0,
            m12: 1.0,
            m21: -1.0,
            m22: 0.0,
            tX: image.size.height,
            tY: 0.0
        )

        self.image = transformedImage(from: image, transform: transform)
    }

    @IBAction
    open func rotateRight(_ sender: Any?) {
        guard let image else { return }

        let transform = NSAffineTransform()
        transform.transformStruct = NSAffineTransformStruct(
            m11: 0.0,
            m12: -1.0,
            m21: 1.0,
            m22: 0.0,
            tX: 0.0,
            tY: image.size.width
        )

        self.image = transformedImage(
            from: image,
            transform: transform
        )
    }

    // MARK: - Utilities

    private func transformedImage(from sourceImage: NSImage, transform: NSAffineTransform) -> NSImage {
        let sourceBounds = NSRect(origin: .zero, size: sourceImage.size)
        let transformedBounds = transform.transform(NSBezierPath(rect: sourceBounds)).bounds
        let transformedImage = NSImage(size: transformedBounds.size, flipped: false) { _ in
            NSGraphicsContext.saveGraphicsState()
            defer {
                NSGraphicsContext.restoreGraphicsState()
            }

            transform.concat()
            sourceImage.draw(in: NSRect(origin: .zero, size: sourceImage.size), from: .zero, operation: .copy, fraction: 1.0)

            return true
        }

        transformedImage.isTemplate = sourceImage.isTemplate
        return transformedImage
    }

}
