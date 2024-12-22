//
//  NSBezierPath.swift
//  AJRInterface
//
//  Created by AJ Raftis on 4/18/23.
//

import AJRInterfaceFoundation
import AppKit

public extension NSBezierPath {
    
    func move<T: BinaryInteger>(to point: (T, T)) -> Void {
        move(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
    }
    
    func move<T: BinaryFloatingPoint>(to point: (T, T)) -> Void {
        move(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
    }
    
    func moveTo<T: BinaryInteger>(x: T, y: T) -> Void {
        move(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
    }
    
    func moveTo<T: BinaryFloatingPoint>(x: T, y: T) -> Void {
        move(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
    }
    
    func line<T: BinaryInteger>(to point: (T, T)) -> Void {
        line(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
    }
    
    func line<T: BinaryFloatingPoint>(to point: (T, T)) -> Void {
        line(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
    }
    
    func lineTo<T: BinaryInteger>(x: T, y: T) -> Void {
        line(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
    }
    
    func lineTo<T: BinaryFloatingPoint>(x: T, y: T) -> Void {
        line(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
    }
    
    func relativeLine<T: BinaryInteger>(to point: (T, T)) -> Void {
        relativeLine(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
    }
    
    func relativeLine<T: BinaryFloatingPoint>(to point: (T, T)) -> Void {
        relativeLine(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
    }
    
    func relativeLineTo<T: BinaryInteger>(x: T, y: T) -> Void {
        relativeLine(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
    }
    
    func relativeLineTo<T: BinaryFloatingPoint>(x: T, y: T) -> Void {
        relativeLine(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
    }
    
    func curve<T: BinaryInteger>(to point: (T, T), controlPoint1 cp1: (T, T), controlPoint2 cp2: (T, T)) -> Void {
        curve(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)),
              controlPoint1: CGPoint(x: CGFloat(cp1.0), y: CGFloat(cp1.1)),
              controlPoint2: CGPoint(x: CGFloat(cp2.0), y: CGFloat(cp2.1)))
    }
    
    func curve<T: BinaryFloatingPoint>(to point: (T, T), controlPoint1 cp1: (T, T), controlPoint2 cp2: (T, T)) -> Void {
        curve(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)),
              controlPoint1: CGPoint(x: CGFloat(cp1.0), y: CGFloat(cp1.1)),
              controlPoint2: CGPoint(x: CGFloat(cp2.0), y: CGFloat(cp2.1)))
    }
    
    func setLineDash(_ dashes: [CGFloat]?, phase: CGFloat = 0.0) -> Void {
        if let dashes {
            var temp = dashes
            temp.withUnsafeMutableBytes { buffer in
                setLineDash(buffer.baseAddress?.assumingMemoryBound(to: CGFloat.self), count: dashes.count, phase: phase)
            }
        } else {
            setLineDash(nil, count: 0, phase: 0.0)
        }
    }
    
    func getLineDash(phase: inout CGFloat?) -> [CGFloat] {
        var count : Int = 0
        var dash : [CGFloat]
        var fetchedPhase : CGFloat = 0.0
        
        getLineDash(nil, count: &count, phase: &fetchedPhase)
        phase? = fetchedPhase
        
        dash = [CGFloat](repeating: 0.0, count: count)
        let raw = UnsafeMutablePointer<CGFloat>.allocate(capacity: count)
        getLineDash(raw, count: nil, phase: nil)
        for x in 0 ..< count {
            dash[x] = raw[x]
        }
        
        return dash
    }
    
}

@objc
public extension NSBezierPath {

    // MARK: - Drawing Conveniences

    @objc(strokeWithColor:)
    func stroke(color: AJRColor) {
        AJRGetCurrentContext()?.drawWithSavedGraphicsState {
            color.set()
            stroke()
        }
    }

    @objc(fillWithColor:)
    func fill(color: AJRColor) {
        AJRGetCurrentContext()?.drawWithSavedGraphicsState {
            color.set()
            fill()
        }
    }

}
