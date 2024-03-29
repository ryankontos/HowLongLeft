//
//  AnimatedGradientView.swift
//  AnimatedGradientView
//
//  Created by Ross Butler on 2/20/19.
//

import Foundation

import CoreGraphics
import Cocoa

public class AnimatedGradientView: NSView {
    
    public typealias Animation = AnimatedGradientViewAnimation
    public typealias AnimationValue = (colors: [String], Direction, CAGradientLayerType)
    public typealias Color = AnimatedGradientViewColor
    public typealias Direction = AnimatedGradientViewDirection
    
    public var gradientAnimations: [Animation]?
    
    private var animationsCount: Int {
        return gradientAnimations?.count ?? 0
    }
    
    public var animationValues: [AnimationValue]? {
        didSet {
            guard let animationValues = animationValues else { return }
            gradientAnimations = animationValues.map { values in
                Animation(colorStrings: values.colors, direction: values.1, type: values.2)
            }
        }
    }
    
    public var autoAnimate: Bool = true {
        didSet {
            if !autoAnimate {
                stopAnimating()
            }
        }
    }
    
    public var autoRepeat: Bool = true
    
    public var drawsAsynchronously = true {
        didSet {
            gradient?.drawsAsynchronously = drawsAsynchronously
        }
    }
    
    public var colors: [[NSColor]] = [[.purple, .orange]]
    public var colorStrings: [[String]] = [[]] {
        didSet {
            colors = colorStrings.map {
                $0.compactMap { Color(string: $0)?.nsColor }
            }
        }
    }
    public var animationDuration: Double = 5.0
    public var direction: Direction = .up {
        didSet {
            gradient?.startPoint = direction.startPoint
            if type == .radial {
                gradient?.startPoint = CGPoint(x: 0.5, y: 0.5)
            }
            if #available(OSX 10.14, *) {
                if type == .conic {
                    gradient?.startPoint = CGPoint(x: 0.5, y: 0.5)
                }
            } else {
                // Fallback on earlier versions
            }
            gradient?.endPoint = direction.endPoint
        }
    }
    public var gridLineColor: NSColor = .white
    public var gridLineOpacity: Float = 0.3
    
    private weak var gradient: CAGradientLayer?
    
    private var currentGradientDirection: Direction {
        return gradientAnimations?[gradientColorIndex % animationsCount].direction ?? direction
    }
    
    private var currentGradientType: CAGradientLayerType {
        return gradientAnimations?[gradientColorIndex % animationsCount].type ?? type
    }
    
    private var gradientCurrentColors: [CGColor] {
        var cgColors: [CGColor]
        if let safeGradientAnimations = gradientAnimations {
            let colorStrings = safeGradientAnimations[gradientColorIndex % safeGradientAnimations.count].colorStrings
            cgColors = colorStrings.compactMap { Color(string: $0)?.nsColor }.map { $0.cgColor }
        } else {
            cgColors = colors[gradientColorIndex % colors.count]
                .map { $0.cgColor }
        }
        let colorsCountDiff = longestColorArrayCount - cgColors.count
        if colorsCountDiff > 0, let lastColor = cgColors.last {
            cgColors += [CGColor](repeating: lastColor, count: colorsCountDiff)
        }
        return cgColors
    }
    
    private var gradientNextColors: [CGColor] {
        gradientColorIndex += 1
        return gradientCurrentColors
    }
    
    private var gradientColorIndex: Int = 0
    
    private var longestColorArrayCount: Int {
        if let gradientAnimations = gradientAnimations {
            return gradientAnimations.reduce(0) { (total, animation) in
                let animationColorCount = animation.colorStrings.count
                return animationColorCount > total ? animationColorCount : total
            }
        }
        return colors.reduce(0) { (total, colors) in
            return colors.count > total ? colors.count : total
        }
    }
    
    public var type: CAGradientLayerType = .axial {
        didSet {
            gradient?.type = type
            if let colors = gradient?.colors as? [CGColor] {
                animate(gradient, to: colors)
            }
        }
    }
    
    // MARK: - View Life Cycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    override public func layout() {
        super.layout()
        guard gradient == nil else {
            gradient?.frame = CGRect(origin: CGPoint.zero, size: bounds.size)
            return
        }
        gradient = configuredGradientLayer()
        if let gradientLayer = gradient {
            gradient!.insertSublayer(gradientLayer, at: 0)
        }
        if autoAnimate {
            animate(gradient, to: gradientNextColors)
        }
    }
}

public extension AnimatedGradientView {
    func startAnimating() {
        if gradient == nil {
            gradient = configuredGradientLayer()
            if let gradientLayer = gradient {
                gradient!.insertSublayer(gradientLayer, at: 0)
            }
        }
        stopAnimating()
        animate(gradient, to: gradientNextColors)
    }
    
    func stopAnimating() {
        gradient?.removeAllAnimations()
    }
}

private extension AnimatedGradientView {
    
    func animate(_ gradient: CAGradientLayer?, to colors: [CGColor]) {
        
        let locationsAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        locationsAnimation.fromValue = gradient?.locations
        locationsAnimation.toValue = locations(for: colors)
        
        let colorsAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.colors))
        colorsAnimation.fromValue = gradient?.colors
        colorsAnimation.toValue = colors
        
        let startPointAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.startPoint))
        startPointAnimation.fromValue = gradient?.startPoint
        startPointAnimation.toValue = startPoint(direction: currentGradientDirection, type: currentGradientType)
        
        let endPointAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.endPoint))
        endPointAnimation.fromValue = gradient?.endPoint
        endPointAnimation.toValue = currentGradientDirection.endPoint
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [colorsAnimation, startPointAnimation, endPointAnimation, locationsAnimation]
        animationGroup.duration = animationDuration
        animationGroup.delegate = self
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = CAMediaTimingFunction(name: .linear)
    
        guard let gradient = self.gradient else { return }
        gradient.colors = colors
        gradient.locations = locations(for: colors)
        gradient.startPoint = startPoint(direction: currentGradientDirection, type: currentGradientType)
        gradient.endPoint = currentGradientDirection.endPoint
        gradient.add(animationGroup, forKey: "gradient-color-\(gradientColorIndex)")
    }
    
    func locations(for colors: [CGColor]) -> [NSNumber] {
        let uniqueColors = colors.uniqueMap({ $0 })
        let colorsCountDiff = colors.count - uniqueColors.count
        var result = locations(colorCount: uniqueColors.count)
        if colorsCountDiff > 0, let lastLocation = result.last {
            result += [NSNumber](repeating: lastLocation, count: colorsCountDiff)
        }
        return result
    }
    
    func locations(colorCount: Int) -> [NSNumber] {
        let animLocations = gradientAnimations?[gradientColorIndex % animationsCount].locations
        if let locations = animLocations {
            return locations
        }
        var result: [NSNumber] = [0.0]
        if colorCount > 2 {
            let increment = 1.0 / (Double(colorCount) - 1.0)
            var location = increment
            repeat {
                result.append(NSNumber(value: location))
                location += increment
            } while location < 1.0
        }
        result.append(1.0)
        return result
    }
    
    func startPoint(direction: Direction, type: CAGradientLayerType) -> CGPoint {
        if #available(OSX 10.14, *) {
            if type == .conic {
                return CGPoint(x: 0.5, y: 0.5)
            } else if type == .radial {
                return CGPoint(x: 0.5, y: 0.5)
            } else {
                return currentGradientDirection.startPoint
            }
        }
        
        fatalError()
        
    }
    
    func configuredGradientLayer() -> CAGradientLayer {
        var startPoint = currentGradientDirection.startPoint
        if type == .radial {
            startPoint = CGPoint(x: 0.5, y: 0.5)
        }
        if #available(OSX 10.14, *) {
            if type == .conic {
                startPoint = CGPoint(x: 0.5, y: 0.5)
            }
        } else {
            // Fallback on earlier versions
        }
        let stopPoint = currentGradientDirection.endPoint
        let gradientSize = bounds.size
        let layer = gradientLayer(from: startPoint, to: stopPoint, colors: gradientCurrentColors, size: gradientSize)
        return layer
    }
    
    private func gradientLayer(from startPoint: CGPoint, to stopPoint: CGPoint,
                               colors: [CGColor], size: CGSize) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.drawsAsynchronously = drawsAsynchronously
        gradientLayer.colors = colors
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = stopPoint
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: size)
        gradientLayer.type = currentGradientType
        return gradientLayer
    }
    
    func gridLine(from startPoint: CGPoint, to stopPoint: CGPoint, color: NSColor, opacity: Float) -> CAShapeLayer {
        let shape = CAShapeLayer()
        shape.path = path(from: startPoint, to: stopPoint)
        shape.strokeColor = color.cgColor
        shape.opacity = opacity
        return shape
    }
    
    private func path(from startPoint: CGPoint, to stopPoint: CGPoint) -> CGPath {
        let path = NSBezierPath()
        path.move(to: startPoint)
        path.line(to: stopPoint)
        return path.cgPath
    }
}

extension AnimatedGradientView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let shouldRepeat = ((gradientColorIndex % (animationsCount + 1)) == 0 && autoRepeat)
            || (gradientColorIndex % (animationsCount + 1)) != 0
        if flag, shouldRepeat, let gradient = self.gradient {
            if currentGradientType != gradient.type {
                type = currentGradientType
            }
            animate(gradient, to: gradientNextColors)
        }
    }
}

extension NSBezierPath {

/// A `CGPath` object representing the current `NSBezierPath`.
var cgPath: CGPath {
    let path = CGMutablePath()
    let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
    let elementCount = self.elementCount
    
    if elementCount > 0 {
        var didClosePath = true
        
        for index in 0..<elementCount {
            let pathType = self.element(at: index, associatedPoints: points)
            
            switch pathType {
            case .moveTo:
                path.move(to: CGPoint(x: points[0].x, y: points[0].y))
            case .lineTo:
                path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
                didClosePath = false
            case .curveTo:
                let control1 = CGPoint(x: points[1].x, y: points[1].y)
                let control2 = CGPoint(x: points[2].x, y: points[2].y)
                path.addCurve(to: CGPoint(x: points[0].x, y: points[0].y), control1: control1, control2: control2)
                didClosePath = false
            case .closePath:
                path.closeSubpath()
                didClosePath = true
            @unknown default:
                fatalError()
            }
        }
        
        if !didClosePath { path.closeSubpath() }
    }
    
    points.deallocate()
    return path
}
}
