//
//  SFProgressHUD.swift
//  SFProgressHUD
//
//  Created by Edmond on 8/22/15.
//  Copyright © 2015 XueQiu. All rights reserved.
//

import UIKit

/**
* Displays a simple HUD window containing a progress indicator and two optional labels for short messages.
*
* This is a simple drop-in class for displaying a progress HUD view similar to Apple's private UIProgressHUD class.
* The ProgressHUD window spans over the entire space given to it by the initWithFrame constructor and catches all
* user input on this region, thereby preventing the user operations on components below the view. The HUD itself is
* drawn centered as a rounded semi-transparent view which resizes depending on the user specified content.
*
* This view supports four modes of operation:
*  - ProgressHUDModeIndeterminate - shows a UIActivityIndicatorView
*  - ProgressHUDModeDeterminate - shows a custom round progress indicator
*  - ProgressHUDModeAnnularDeterminate - shows a custom annular progress indicator
*  - ProgressHUDModeCustomView - shows an arbitrary, user specified view (see `customView`)
*
* All three modes can have optional labels assigned:
*  - If the labelText property is set and non-empty then a label containing the provided content is placed below the
*    indicator view.
*  - If also the detailsLabelText property is set then another label is placed below the first label.
*/

let kPadding : CGFloat = 4.0

public class SFProgressHUD : UIView {
    
    
    var mode : SFProgressHUDMode = .Indeterminate
    var customView : UIView?
    var indicator : UIView?
    var color : UIColor?
    var opacity : CGFloat = 0.8
    var xOffset : CGFloat = 0.0
    var yOffset : CGFloat = 0.0
    var margin : CGFloat = 20.0
    var cornerRadius : CGFloat = 10.0
    var graceTime : Float = 0.0
    var minShowTime : NSTimeInterval = 0.0
    var progress : Double = 0.0
    var minSize : CGSize = CGSizeZero
    var size : CGSize = CGSizeZero
    var square : Bool = false
    var dimBackground : Bool = false
    var hudWasHidden : (() -> ())?
    var hudCompletion : (() -> ())?
    
    private var isFinished : Bool = false
    private var useAnimation : Bool = false
    private var taskInProgress : Bool = false
    
    private var removeFromSuperViewOnHide : Bool = false
    private var rotationTransform = CGAffineTransformIdentity
    private var showStarted : NSDate?
    private var graceTimer : NSTimer?
    private var minShowTimer : NSTimer?
    
    
    static let labelFontSize : CGFloat = 16
    static let detailsLabelFontSize : CGFloat = 12
    
    
    /// MARK: class Method
    
    public class func showHUD(view: UIView, animated: Bool) -> SFProgressHUD {
        let hud: SFProgressHUD = SFProgressHUD(view:view)
        hud.removeFromSuperViewOnHide = true
        view.addSubview(hud)
        hud.show(animated)
        return hud
    }
    
    public class func hideHUD(view: UIView, animated: Bool) -> Bool {
        if let hud = SFProgressHUD.HUD(view) {
            hud.removeFromSuperViewOnHide = true
            hud.hide(animated)
            return true
        }
        return false
    }
    
    public class func hideAllHUDs(onView: UIView, animated: Bool) -> Bool {
        var result = false
        if let huds = self.allHUDs(onView) {
            for hud in huds {
                hud.removeFromSuperViewOnHide = true
                hud.hide(animated)
            }
            result = true
        }
        return result
    }
    
    public class func HUD(onView: UIView) -> SFProgressHUD? {
        for case let hud as SFProgressHUD in onView.subviews {
            return hud
        }
        return nil
    }
    
    public class func allHUDs(onView: UIView) -> [SFProgressHUD]? {
        var huds = [SFProgressHUD]()
        for case let hud as SFProgressHUD in onView.subviews {
            huds.append(hud)
        }
        return huds.count > 0 ? huds : nil
    }
    
    
    /// show && hide
    
    public func show(animated: Bool) {
        assert(NSThread.isMainThread(), "ProgressHUD needs to be accessed on the main thread.")
        useAnimation = animated
        if (self.graceTime > 0.0) {
            let timer = NSTimer(timeInterval: 1, target: self, selector: "handleGraceTimer:",
                userInfo: nil, repeats: false)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode:NSRunLoopCommonModes)
        } else {
            self.showUsingAnimation(useAnimation)
        }
    }
    
    public func hide(animated: Bool) {
        assert(NSThread.isMainThread(), "ProgressHUD needs to be accessed on the main thread.")
        useAnimation = animated;
        // If the minShow time is set, calculate how long the hud was shown,
        // and pospone the hiding operation if necessary
        if (minShowTime > 0.0 && showStarted != nil) {
            let interv = NSDate().timeIntervalSinceDate(showStarted!)
            if (interv < minShowTime) {
                minShowTimer = NSTimer.scheduledTimerWithTimeInterval(minShowTime - interv, target:self, selector:"handleMinShowTimer:", userInfo:nil, repeats:false)
                return
            }
        }
        // ... otherwise hide the HUD immediately
        self.hideUseAnimation(useAnimation)
    }
    
    public func hide(animated: Bool, afterDelay: NSTimeInterval) {
        self.performSelector("hideDelayed:", withObject:NSNumber(bool:animated), afterDelay:afterDelay)
    }
    
    public func hideDelayed(animated: NSNumber) {
        self.hide(animated.boolValue)
    }
    
    // Timer CallBack
    func handleGraceTimer(timer: NSTimer) {
        if taskInProgress {
            self.showUsingAnimation(useAnimation)
        }
    }
    
    func handleMinShowTimer(timer: NSTimer) {
        self.hideUseAnimation(useAnimation)
    }
    
    override public func didMoveToSuperview() {
        self._sf_updateForCurrentOrientationAnimated(false)
    }
    
    
    private func showUsingAnimation(animated: Bool) {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        self.setNeedsDisplay()
        
        self.showStarted = NSDate()
        if animated {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.alpha = 1.0
            })
        } else {
            self.alpha = 1.0
        }
    }
    
    private func hideUseAnimation(animated: Bool) {
        if (animated && showStarted != nil) {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.alpha = 0.02
                }, completion: { (finished) -> Void in
                    self.done()
            })
        } else {
            self.done()
        }
        self.showStarted = nil
    }
    
    private func done() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        isFinished = true
        self.alpha = 0.0
        if removeFromSuperViewOnHide {
            self.removeFromSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = 0.0
        self.opaque = false
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Center
        self.taskInProgress = false
        self.rotationTransform = CGAffineTransformIdentity
        
        self.addSubview(label)
        self.addSubview(detailsLabel)
        
        _sf_registeNotifications()
        _sf_registerForKVO()
    }
    
    deinit {
        _sf_unregisterFromKVO()
        _sf_unregisteNotifications()
    }
    
    //  show on view
    public convenience init(view: UIView) {
        self.init(frame:view.bounds)
    }
    
    public convenience init(window: UIView) {
        self.init(view:window)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        // Entirely cover the parent view
        if let parent = self.superview {
            self.frame = parent.bounds
        }
        let bounds = self.bounds
        
        // Determine the total widt and height needed
        let maxWidth = bounds.size.width - 4 * margin
        var totalSize = CGSizeZero
        
        var indicatorF = CGRectZero
        if let indicator = indicator {
            indicatorF = indicator.bounds
            indicatorF.size.width = min(indicatorF.size.width, maxWidth)
            totalSize.width = max(totalSize.width, indicatorF.size.width)
            totalSize.height += indicatorF.size.height
        }
        
        var labelSize = _sf_textSize(label.text, font:label.font)
        labelSize.width = min(labelSize.width, maxWidth)
        totalSize.width = min(totalSize.width, labelSize.width)
        totalSize.height += labelSize.height
        if (labelSize.height > 0.0 && indicatorF.size.height > 0.0) {
            totalSize.height += kPadding
        }
        
        let remainingHeight = bounds.size.height - totalSize.height - kPadding - 4 * margin
        let maxSize = CGSizeMake(maxWidth, remainingHeight)
        let detailsLabelSize = _sf_mutilLineTextSize(detailsLabel.text, font:detailsLabel.font, maxSize:maxSize)
        totalSize.width = max(totalSize.width, detailsLabelSize.width)
        totalSize.height += detailsLabelSize.height
        if (detailsLabelSize.height > 0.0 && (indicatorF.size.height > 0.0 || labelSize.height > 0.0)) {
            totalSize.height += kPadding
        }
        
        totalSize.width += 2 * margin
        totalSize.height += 2 * margin
        
        // Position elements
        var yPos = round(((bounds.size.height - totalSize.height) / 2)) + margin + yOffset
        let xPos = xOffset
        indicatorF.origin.y = yPos
        indicatorF.origin.x = round((bounds.size.width - indicatorF.size.width) / 2) + xPos
        if let indicator = indicator {
            indicator.frame = indicatorF
        }
        yPos += indicatorF.size.height
        
        if (labelSize.height > 0.0 && indicatorF.size.height > 0.0) {
            yPos += kPadding
        }
        var labelF = CGRectZero
        labelF.origin.y = yPos
        labelF.origin.x = round((bounds.size.width - labelSize.width) / 2) + xPos
        labelF.size = labelSize
        label.frame = labelF
        yPos += labelF.size.height
        
        if (detailsLabelSize.height > 0.0 && (indicatorF.size.height > 0.0 || labelSize.height > 0.0)) {
            yPos += kPadding
        }
        var detailsLabelF = CGRectZero
        detailsLabelF.origin.y = yPos
        detailsLabelF.origin.x = round((bounds.size.width - detailsLabelSize.width) / 2) + xPos
        detailsLabelF.size = detailsLabelSize
        detailsLabel.frame = detailsLabelF
        
        // Enforce minsize and quare rules
        if (square) {
            let maxValue = max(totalSize.width, totalSize.height)
            if (maxValue <= bounds.size.width - 2 * margin) {
                totalSize.width = maxValue
            }
            if (maxValue <= bounds.size.height - 2 * margin) {
                totalSize.height = maxValue
            }
        }
        if (totalSize.width < minSize.width) {
            totalSize.width = minSize.width
        } 
        if (totalSize.height < minSize.height) {
            totalSize.height = minSize.height
        }
        
        size = totalSize
    }
    
    public override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context!)
        
        if dimBackground {
            //Gradient colours
            let gradLocationsNum: size_t = 2
            let gradLocations: [CGFloat] = [0.0, 1.0]
            let gradColors: [CGFloat] = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.75]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
            
            //Gradient center
            let gradCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
            //Gradient radius
            let gradRadius = min(self.bounds.size.width , self.bounds.size.height) ;
            //Gradient draw
            CGContextDrawRadialGradient(context, gradient, gradCenter, 0, gradCenter, gradRadius, .DrawsAfterEndLocation)
        }
        
        // Set background rect color
        if let color = color {
            CGContextSetFillColorWithColor(context, color.CGColor);
        } else {
            CGContextSetGrayFillColor(context, 0.0, opacity);
        }
        
        // Center HUD
        let allRect = self.bounds
        // Draw rounded HUD backgroud rect
        let boxRect = CGRectMake(round((allRect.size.width - size.width) / 2) + self.xOffset,
            round((allRect.size.height - size.height) / 2) + self.yOffset, size.width, size.height)
        let radius = self.cornerRadius
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect))
        CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMinY(boxRect) + radius, radius, CGFloat(3 * M_PI / 2), 0, 0)
        CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMaxY(boxRect) - radius, radius, 0, CGFloat(M_PI / 2), 0)
        CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMaxY(boxRect) - radius, radius, CGFloat(M_PI / 2), CGFloat(M_PI), 0)
        CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect) + radius, radius, CGFloat(M_PI),
            CGFloat(3 * M_PI / 2), 0)
        CGContextClosePath(context)
        CGContextFillPath(context)
        
        UIGraphicsPopContext()
    }
    
    func _sf_registerForKVO() {
        for keyPath in self._sf_observableKeypaths() {
            self.addObserver(self, forKeyPath:keyPath, options:.New, context:nil)
        }
    }
    
    func _sf_unregisterFromKVO() {
        for keyPath in self._sf_observableKeypaths() {
            self.removeObserver(self, forKeyPath:keyPath)
        }
    }
    
    func _sf_observableKeypaths() -> [String] {
        return ["mode",
            "customView",
            "progress",
            "activityIndicatorColor"]
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !NSThread.isMainThread() {
            self.performSelectorOnMainThread("_sf_updateUIForKeypath", withObject:keyPath, waitUntilDone: false)
        } else {
            _sf_updateUIForKeypath(keyPath!)
        }
    }
    
    func _sf_updateUIForKeypath(keyPath: String) {
        if keyPath == "mode" || keyPath == "customView" || keyPath == "activityIndicatorColor" {
            self._sf_updateIndicator()
        } else if keyPath == "progress" {
            if let indicator = indicator as? SFRoundProgressView {
                indicator.progress = progress
            }
            return
        }
        self.setNeedsLayout()
        self.setNeedsDisplay()
    }
    
    // MARK: Notifications
    
    func _sf_registeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"statusBarOrientationDidChange:", name:UIApplicationDidChangeStatusBarOrientationNotification, object:nil)
    }
    
    func _sf_unregisteNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIApplicationDidChangeStatusBarOrientationNotification, object:nil)
    }
    
    func statusBarOrientationDidChange(notification: NSNotification) {
        if self.superview != nil {
            return
        } else {
            self._sf_updateForCurrentOrientationAnimated(true)
        }
    }
    
    func _sf_updateForCurrentOrientationAnimated(animated: Bool) {
        // Stay in sync with the superview in any case
        if let superview = self.superview {
            bounds = superview.bounds
            self.setNeedsDisplay()
        }
    }
    
    func _sf_updateIndicator() {
        let isActivityIndicator : Bool = indicator is UIActivityIndicatorView
        let isRoundIndicator : Bool = indicator is SFRoundProgressView
        
        if (mode == .Indeterminate) {
            if (!isActivityIndicator) {
                // Update to indeterminate indicator
                if indicator != nil {
                    indicator!.removeFromSuperview()
                    indicator = UIActivityIndicatorView(activityIndicatorStyle:.WhiteLarge)
                    (indicator as! UIActivityIndicatorView).startAnimating()
                    self.addSubview(indicator!)
                }
            }
        } else if (mode == .Determinate || mode == .AnnularDeterminate) {
            if (!isRoundIndicator) {
                // Update to determinante indicator
                indicator!.removeFromSuperview()
                indicator = SFRoundProgressView()
                self.addSubview(indicator!)
            }
            if (mode == .AnnularDeterminate) {
                let progressView = indicator as! SFRoundProgressView
                progressView.annular = true
            }
        }
        else if (mode == .CustomView && customView != indicator) {
            // Update custom view indicator
            indicator!.removeFromSuperview()
            indicator = customView
            self.addSubview(indicator!)
        } else if (mode == .Text) {
            indicator!.removeFromSuperview()
            indicator = nil
        }
    }
    
    func _sf_textSize(text: String?, font: UIFont) -> CGSize {
        if let text = text where text.characters.count > 0 {
            return text.sizeWithAttributes([NSFontAttributeName : font])
        } else {
            return CGSizeZero
        }
    }

    func _sf_mutilLineTextSize(text: String?, font: UIFont, maxSize: CGSize) -> CGSize {
        if let text = text where text.characters.count > 0 {
            return text.boundingRectWithSize(maxSize, options:.UsesLineFragmentOrigin, attributes:[NSFontAttributeName : font], context:nil).size
        } else {
            return CGSizeZero
        }
    }
    
    lazy var label : UILabel = {
        let label = UILabel(frame: self.bounds)
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = .Center
        label.opaque = false
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont.boldSystemFontOfSize(labelFontSize)
        label.textColor = UIColor.whiteColor()
        return label
        }()
    
    lazy var detailsLabel : UILabel = {
        let detailsLabel = UILabel(frame: self.bounds)
        detailsLabel.adjustsFontSizeToFitWidth = false
        detailsLabel.textAlignment = .Center
        detailsLabel.opaque = false
        detailsLabel.backgroundColor = UIColor.clearColor()
        detailsLabel.font = UIFont.boldSystemFontOfSize(detailsLabelFontSize)
        detailsLabel.textColor = UIColor.whiteColor()
        return detailsLabel
        }()
    
    public enum SFProgressHUDMode {
        /** Progress is shown using an UIActivityIndicatorView. This is the default. */
        case Indeterminate
        /** Progress is shown using a round, pie-chart like, progress view. */
        case Determinate
        /** Progress is shown using a ring-shaped progress view. */
        case AnnularDeterminate
        /** Shows a custom view */
        case CustomView
        /** Shows only labels */
        case Text
    }
}

/// Provides the general look and feel of the APPLE HUD,
/// into which the eventual content is inserted.
class SFHUDView: UIVisualEffectView {
    init() {
        super.init(effect: UIBlurEffect(style: .Light))
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor(white: 0.8, alpha: 0.36)
        layer.cornerRadius = 9.0
        layer.masksToBounds = true
        
        contentView.addSubview(self.content)
        
        let offset = 20.0
        
        let motionEffectsX = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        motionEffectsX.maximumRelativeValue = offset
        motionEffectsX.minimumRelativeValue = -offset
        
        let motionEffectsY = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        motionEffectsY.maximumRelativeValue = offset
        motionEffectsY.minimumRelativeValue = -offset
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [motionEffectsX, motionEffectsY]
        
        addMotionEffect(group)
    }
    
    private var _content = UIView()
    internal var content: UIView {
        get {
            return _content
        }
        set {
            _content.removeFromSuperview()
            _content = newValue
            _content.alpha = 0.85
            _content.clipsToBounds = true
            _content.contentMode = .Center
            frame.size = _content.bounds.size
            addSubview(_content)
        }
    }
}

class SFRoundProgressView : UIView {
    var progress : Double = 0.0
    var progressTintColor : UIColor?
    var backgroundTintColor : UIColor?
    var annular : Bool = false
    
    override func drawRect(rect: CGRect) {
        let allRect = self.bounds;
        let circleRect = CGRectInset(allRect, 2.0, 2.0);
        let context = UIGraphicsGetCurrentContext();
        
        if (annular) {
            // Draw background
            let  lineWidth: CGFloat = 2.0
            let processBackgroundPath = UIBezierPath()
            processBackgroundPath.lineWidth = lineWidth
            processBackgroundPath.lineCapStyle = .Butt
            let center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
            let radius = (self.bounds.size.width - lineWidth)/2
            let startAngle = -(M_PI / 2) // 90 degrees
            var endAngle =  2 * M_PI + startAngle
            processBackgroundPath.addArcWithCenter(center, radius:radius, startAngle:CGFloat(startAngle), endAngle:CGFloat(endAngle), clockwise: true)
            backgroundTintColor?.set()
            processBackgroundPath.stroke()
            // Draw progress
            let processPath = UIBezierPath()
            processPath.lineCapStyle = .Square
            processPath.lineWidth = lineWidth
            endAngle = self.progress * 2 * M_PI + startAngle
            processPath.addArcWithCenter(center, radius:radius, startAngle:CGFloat(startAngle), endAngle:CGFloat(endAngle), clockwise: true)
            progressTintColor?.set()
            processPath.stroke()
        } else {
            // Draw background
            progressTintColor?.setStroke()
            backgroundTintColor?.setFill()
            CGContextSetLineWidth(context, 2.0)
            CGContextFillEllipseInRect(context, circleRect)
            CGContextStrokeEllipseInRect(context, circleRect)
            // Draw progress
            let center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2)
            let radius = (allRect.size.width - 4) / 2
            let startAngle = -(M_PI / 2) // 90 degrees
            let endAngle = progress * 2 * M_PI + startAngle
            progressTintColor?.setFill()
            CGContextMoveToPoint(context, center.x, center.y)
            CGContextAddArc(context, center.x, center.y, radius, CGFloat(startAngle), CGFloat(endAngle), 0)
            CGContextClosePath(context)
            CGContextFillPath(context)
        }
    }
    
    deinit {
        _sf_unregisterFromKVO()
    }
    
    // MARK: KVO
    func _sf_registerForKVO() {
        for keyPath in self._sf_observableKeypaths() {
            self.addObserver(self, forKeyPath:keyPath, options:.New, context:nil)
        }
    }
    
    func _sf_unregisterFromKVO() {
        for keyPath in self._sf_observableKeypaths() {
            self.removeObserver(self, forKeyPath:keyPath)
        }
    }
    
    func _sf_observableKeypaths() -> [String] {
        return ["progressTintColor",
            "backgroundTintColor",
            "progress",
            "annular"]
    }
    
    override internal func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.setNeedsDisplay()
    }
}
