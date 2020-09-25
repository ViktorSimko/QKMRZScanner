//
//  QKCutoutView.swift
//  QKMRZScanner
//
//  Created by Matej Dorcak on 05/10/2018.
//

import UIKit

class QKCutoutView: UIView {
    fileprivate(set) var cutoutRect: CGRect!
    fileprivate(set) var mrzRect: CGRect!
    var type: QKMRZScannerViewType = .ID

    var mrzHeightRatio: CGFloat {
        if type == .ID {
            return 3
        } else {
            return 5
        }
    }

    var mrzNumberOfLines: CGFloat {
        if type == .ID {
            return 3
        } else {
            return 2
        }
    }

    var mrzLine: String {
        if type == .ID {
            return "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        } else {
            return "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        }
    }

    var mrzInset: CGFloat {
        return cutoutRect.width / mrzHeightRatio / 7
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //backgroundColor = UIColor.black.withAlphaComponent(0.45)
        contentMode = .redraw // Redraws everytime the bounds (orientation) changes
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        cutoutRect = calculateCutoutRect() // Orientation or the view's size could change
        mrzRect = calculateMRZRect()
        layer.sublayers?.removeAll()
        drawRectangleCutout()
    }
    
    // MARK: Misc
    fileprivate func drawRectangleCutout() {
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        let cornerRadius = CGFloat(3)
        
        path.addRoundedRect(in: cutoutRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
        path.addRect(bounds)
        
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd

        let outsideArea = CALayer()
        outsideArea.frame = frame
        outsideArea.backgroundColor = UIColor.black.withAlphaComponent(0.45).cgColor
        outsideArea.mask = maskLayer
        layer.addSublayer(outsideArea)
        
        // Add border around the cutout
        let borderLayer = CAShapeLayer()
        
        borderLayer.path = UIBezierPath(roundedRect: cutoutRect, cornerRadius: cornerRadius).cgPath
        borderLayer.lineWidth = 3
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = bounds
        
        layer.addSublayer(borderLayer)

        let rmzLineLayer = CAShapeLayer()

        rmzLineLayer.path = UIBezierPath(roundedRect:
            CGRect(
                x: cutoutRect.minX + cutoutRect.width / mrzHeightRatio,
                y: cutoutRect.minY,
                width: 1,
                height: cutoutRect.height
            ),
            cornerRadius: 0
        ).cgPath
        rmzLineLayer.lineWidth = 1.5
        rmzLineLayer.strokeColor = UIColor.white.cgColor
        rmzLineLayer.frame = bounds

        layer.addSublayer(rmzLineLayer)

        for i in 0..<Int(mrzNumberOfLines) {
            layer.addSublayer(createTextLayer(downOffset: CGFloat(i) * mrzRect.width / mrzNumberOfLines))
        }
    }

    fileprivate func createTextLayer(downOffset: CGFloat = 0.0) -> CATextLayer {
        let text = CATextLayer()
        text.string = mrzLine

        text.frame = CGRect(
            x: cutoutRect.minX - cutoutRect.height,
            y: cutoutRect.maxY - cutoutRect.width / mrzHeightRatio,
            width: cutoutRect.height,
            height: cutoutRect.width / mrzHeightRatio
        ).inset(by: .init(top: mrzInset, left: mrzInset, bottom: mrzInset, right: mrzInset))
        let rotationPoint = CGPoint(
            x: cutoutRect.minX,
            y: cutoutRect.maxY
        )
        let c = CGPoint(
            x: text.frame.midX,
            y: text.frame.midY
        )

        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, rotationPoint.x - c.x, rotationPoint.y - c.y, 0.0)
        transform = CATransform3DRotate(transform, CGFloat.pi / 2, 0.0, 0.0, 1.0)
        transform = CATransform3DTranslate(transform, c.x - rotationPoint.x, c.y - rotationPoint.y, 0.0)
        transform = CATransform3DTranslate(transform, 0, downOffset, 0.0)
        text.transform = transform
        text.contentsScale = UIScreen.main.scale

        var fontSize: CGFloat = 20
        var font = UIFont(name: "OCRB", size: fontSize)!

        while (mrzLine as NSString).size(withAttributes: [.font: font]).width > text.frame.height {
            fontSize -= 1
            font = UIFont(name: "OCRB", size: fontSize)!
        }

        text.foregroundColor = UIColor.white.withAlphaComponent(0.65).cgColor
        text.font = font
        text.fontSize = fontSize
        text.isWrapped = true
        text.alignmentMode = .center

        return text
    }
    
    fileprivate func calculateCutoutRect() -> CGRect {
        let documentFrameRatio = CGFloat(1.42) // Passport's size (ISO/IEC 7810 ID-3) is 125mm × 88mm
        let (width, height): (CGFloat, CGFloat)

        width = (bounds.width * 0.9)
        height = (width * documentFrameRatio)
        
        let topOffset = (bounds.height - height) / 2
        let leftOffset = (bounds.width - width) / 2
        
        return CGRect(x: leftOffset, y: topOffset, width: width, height: height)
    }

    fileprivate func calculateMRZRect() -> CGRect {
        return CGRect(
            x: cutoutRect.minX,
            y: cutoutRect.minY,
            width: cutoutRect.width / mrzHeightRatio,
            height: cutoutRect.height
        ).inset(by: .init(top: mrzInset, left: mrzInset, bottom: mrzInset, right: mrzInset))
    }
}
