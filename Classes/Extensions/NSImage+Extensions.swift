/*
 NSImage+Extensions.swift
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation

// Defines some useful extensions.
public extension String {
    static let sfFolder = "folder"
    static let sfFolderFill = "folder.fill"
    static let sfDoc = "doc"
    static let sfGear = "gear"
    static let sfChevronRight = "chevron.right"                 // Finder-style disclosure
    static let sfChevronForward = "chevron.forward"             // Semantic "forward" navigation
    static let sfChevronCompactRight = "chevron.compact.right"  // Shorter chevron
    static let sfArrowRight = "arrow.right"                     // Full arrow
    static let sfArrowForward = "arrow.forward"                 // Semantic forward arrow}
    static let sfRotateLeft = "rotate.left"
    static let sfRotateRight = "rotate.right"
    static let sfFlipHorizontal = "flip.horizontal"
    static let sfFlipVertical = "arrow.up.and.down.righttriangle.up.righttriangle.down"
    static let sfCrop = "crop"
    static let sfHome = "house"
    static let sfNavigateBack = "chevron.backward"
    static let sfNavigateForward = "chevron.forward"
    static let sfSafari = "safari"
}

public extension NSImage {

    var basicCGImage : CGImage? {
        return cgImage(forProposedRect: nil, context: nil, hints: nil)
    }

    class var imageUTTypes : [UTType] {
        return imageTypes.compactMap { uti in
            return UTType(uti)
        }
    }

    /**
     Returns a new image by adding transparent padding around the receiver, while
     preserving its multi-representation behavior by generating padded raster
     representations for each underlying image representation.

     This method creates a new `NSImage` whose logical size (in points) is increased by
     the specified edge insets. For each representation in the receiver, a corresponding
     raster representation is generated. Raster-backed representations preserve their
     effective scale (e.g. 1×, 2×, 3×). Representations that can provide a `CGImage`
     (including private CG-backed AppKit representations) are treated as raster sources.
     Other representations (such as PDF/vector) are rasterized.

     - Parameter insets: The amount of padding to apply to each edge, in points.
     - Returns: A new padded image, or `nil` if no drawable representations were found.

     - Note:
     - Uses `cgImage(forProposedRect:...)` to safely handle both public and private
     CG-backed representations.
     - All output representations are raster (`NSBitmapImageRep`).
     - The `isTemplate` property is preserved.
     - Insets are converted to pixels per representation based on its scale.
     - Vector representations are rasterized.
     */
    func imageByAddingInsets(_ insets: NSEdgeInsets) -> NSImage? {
        let originalSize = size
        let newSize = NSSize(
            width: max(0, originalSize.width + insets.left + insets.right),
            height: max(0, originalSize.height + insets.top + insets.bottom)
        )

        guard newSize.width > 0, newSize.height > 0 else { return nil }

        let result = NSImage(size: newSize)
        var added = false

        for rep in representations {
            guard let destRep = Self.makeRep(from: rep,
                                             imageSize: originalSize,
                                             newSize: newSize,
                                             insets: insets) else {
                continue
            }

            result.addRepresentation(destRep)
            added = true
        }

        guard added else { return nil }

        result.isTemplate = isTemplate
        return result
    }

    private static func makeRep(
        from rep: NSImageRep,
        imageSize: NSSize,
        newSize: NSSize,
        insets: NSEdgeInsets
    ) -> NSBitmapImageRep? {

        var proposedRect = NSRect(origin: .zero, size: rep.size.width > 0 ? rep.size : imageSize)

        if let cgImage = rep.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil) {
            // Raster path (covers NSBitmapImageRep + CG-backed reps)

            let pixelWidth = cgImage.width
            let pixelHeight = cgImage.height

            let logicalSize = proposedRect.size

            guard logicalSize.width > 0, logicalSize.height > 0 else { return nil }

            let scaleX = CGFloat(pixelWidth) / logicalSize.width
            let scaleY = CGFloat(pixelHeight) / logicalSize.height

            let left = Int((insets.left * scaleX).rounded())
            let right = Int((insets.right * scaleX).rounded())
            let top = Int((insets.top * scaleY).rounded())
            let bottom = Int((insets.bottom * scaleY).rounded())

            let newPixelWidth = pixelWidth + left + right
            let newPixelHeight = pixelHeight + top + bottom

            guard newPixelWidth > 0, newPixelHeight > 0 else { return nil }

            guard let destRep = NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: newPixelWidth,
                pixelsHigh: newPixelHeight,
                bitsPerSample: 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: .deviceRGB,
                bitmapFormat: [.alphaFirst],
                bytesPerRow: 0,
                bitsPerPixel: 0
            ) else { return nil }

            destRep.size = newSize

            guard let ctx = NSGraphicsContext(bitmapImageRep: destRep) else { return nil }

            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = ctx
            ctx.imageInterpolation = .high

            let drawRect = NSRect(
                x: insets.left,
                y: insets.bottom,
                width: logicalSize.width,
                height: logicalSize.height
            )

            NSGraphicsContext.current?.cgContext.draw(cgImage, in: drawRect)

            NSGraphicsContext.restoreGraphicsState()

            return destRep
        }

        // Fallback: draw via NSImageRep (vector, etc.)
        let scale = NSScreen.main?.backingScaleFactor ?? 1.0

        let pixelWidth = Int((imageSize.width * scale).rounded())
        let pixelHeight = Int((imageSize.height * scale).rounded())

        let left = Int((insets.left * scale).rounded())
        let right = Int((insets.right * scale).rounded())
        let top = Int((insets.top * scale).rounded())
        let bottom = Int((insets.bottom * scale).rounded())

        guard let destRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixelWidth + left + right,
            pixelsHigh: pixelHeight + top + bottom,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bitmapFormat: [.alphaFirst],
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else { return nil }

        destRep.size = newSize

        guard let ctx = NSGraphicsContext(bitmapImageRep: destRep) else { return nil }

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = ctx

        let drawRect = NSRect(
            x: insets.left,
            y: insets.bottom,
            width: imageSize.width,
            height: imageSize.height
        )

        rep.draw(in: drawRect)

        NSGraphicsContext.restoreGraphicsState()

        return destRep
    }

    @objc func transform(using transform: NSAffineTransform) -> NSImage {
        let sourceBounds = NSRect(origin: .zero, size: self.size)
        let transformedBounds = transform.transform(NSBezierPath(rect: sourceBounds)).bounds
        let transformedImage = NSImage(size: transformedBounds.size, flipped: false) { _ in
            NSGraphicsContext.saveGraphicsState()
            defer {
                NSGraphicsContext.restoreGraphicsState()
            }

            transform.concat()
            self.draw(in: NSRect(origin: .zero, size: self.size), from: .zero, operation: .copy, fraction: 1.0)

            return true
        }

        transformedImage.isTemplate = self.isTemplate
        return transformedImage
    }

    @objc func cropped(to rect: NSRect) -> NSImage {
        let imageBounds = NSRect(origin: .zero, size: size)
        let cropRect = rect.standardized.intersection(imageBounds)

        guard !cropRect.isEmpty else {
            return self
        }

        let croppedImage = NSImage(size: cropRect.size)
        croppedImage.lockFocus()
        self.draw(
            in: NSRect(origin: .zero, size: cropRect.size),
            from: cropRect,
            operation: .copy,
            fraction: 1.0
        )
        croppedImage.unlockFocus()

        croppedImage.isTemplate = isTemplate
        return croppedImage
    }

    @objc var flipVerticalTransform : NSAffineTransform {
        let transform = NSAffineTransform()
        transform.transformStruct = NSAffineTransformStruct(
            m11: 1.0,
            m12: 0.0,
            m21: 0.0,
            m22: -1.0,
            tX: 0.0,
            tY: self.size.height
        )
        return transform
    }

    @objc var flipHorizontalTransform : NSAffineTransform {
        let transform = NSAffineTransform()
        transform.transformStruct = NSAffineTransformStruct(
            m11: -1.0,
            m12: 0.0,
            m21: 0.0,
            m22: 1.0,
            tX: size.width,
            tY: 0.0
        )
        return transform
    }

    @objc var rotateLeftTransform : NSAffineTransform {
        let transform = NSAffineTransform()
        transform.transformStruct = NSAffineTransformStruct(
            m11: 0.0,
            m12: 1.0,
            m21: -1.0,
            m22: 0.0,
            tX: size.height,
            tY: 0.0
        )
        return transform
    }

    @objc var rotateRightTransform : NSAffineTransform {
        let transform = NSAffineTransform()
        transform.transformStruct = NSAffineTransformStruct(
            m11: 0.0,
            m12: -1.0,
            m21: 1.0,
            m22: 0.0,
            tX: 0.0,
            tY: size.width
        )
        return transform
    }

}
