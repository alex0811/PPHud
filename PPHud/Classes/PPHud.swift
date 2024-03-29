//
//  PPHud.swift
//  Pods
//
//  Created by Alex on 2020/8/7.
//  Copyright © 2020 Fan Zhang. All rights reserved.
//

import UIKit

public enum PPHudMode {
    case indeterminate
    case determinate
    case determinateHorizontalBar
    case annularDeteminate
    case customView
    case text
}

public enum PPHudAnimateMode {
    case fade       /// apear fade, disapear fade
    case zoom       /// appear out, dispear in
    case zoomOut    /// apear out, dispear out
    case zoomIn     /// apear in, disapear in
    case fadeInZoomOut /// appear fade, disapear zoom in
}

public class PPHud: UIView {
    let PPDefaultLabelFontSize: CGFloat = 16.0
    let PPDefaultDetailLabelFontSize: CGFloat = 12.0
    let PPDefaultPadding = 4.0
    let animationInterval = 0.35
    let PPDefaultBackgroundColor = UIColor(white: 0.0, alpha: 0.1)
    var margin = 20.0
    
    private var overParentView: UIView?
    var indicator: UIView?
    public var label: UILabel = UILabel()
    public var detailLabel: UILabel = UILabel()
    public var button: UIButton = PPHudRoundButton(type: .custom)
    public var backgroundView: PPBackgroundView = PPBackgroundView()
    var bezelView: PPBackgroundView = PPBackgroundView()
    var isShowing: Bool = false
    public var animateMode: PPHudAnimateMode = .fadeInZoomOut
    var bezelConstraints = [NSLayoutConstraint]()
    
    public var contentColor: UIColor = UIColor.black {
        willSet {
            if newValue != self.contentColor {
                self.contentColor = newValue
                self.updateViewForColor()
            }
        }
    }
    
    public var customView: UIView? {
        didSet {
            self.updateIndicators()
        }
    }
    
    public var propress: CGFloat = 0.0 {
        willSet {
            if newValue != self.propress {
                self.propress = newValue
                if self.mode == .determinate || self.mode == .annularDeteminate {
                    if let indicator = self.indicator, indicator.isKind(of: PPRoundProgressView.self) {
                        (indicator as! PPRoundProgressView).progress = self.propress
                    }
                } else if self.mode == .determinateHorizontalBar {
                    if let indicator = self.indicator, indicator.isKind(of: PPBarProgressView.self) {
                        (indicator as! PPBarProgressView).progress = self.propress
                    }
                }
            }
        }
    }
    
    public var text: String? = "" {
        didSet {
            self.label.text = self.text
            self.updateConstraints()
        }
    }
    
    public var detail: String? = "" {
        didSet {
            self.detailLabel.text = self.detail
            self.updateConstraints()
        }
    }
    
    public var mode: PPHudMode = .indeterminate {
        willSet {
            if newValue != self.mode {
                self.mode = newValue
                self.updateIndicators()
            }
        }
    }
    
    public var enbaleBackgroundGesture: Bool = false {
        didSet {
            self.backgroundView.isUserInteractionEnabled = !self.enbaleBackgroundGesture
            self.isUserInteractionEnabled = !self.enbaleBackgroundGesture
            self.overParentView?.isUserInteractionEnabled = !self.enbaleBackgroundGesture
        }
    }
    
    // MARK: - Override
    public override func didMoveToSuperview() {
        if let parentView = self.superview {
            if parentView.isKind(of: UIScrollView.self) {
                if let grandFatherView = parentView.superview {
                    let overView = UIView.init(frame: parentView.frame)
                    grandFatherView.insertSubview(overView, aboveSubview: parentView)
                    self.removeFromSuperview()
                    self.overParentView = overView
                    overView.addSubview(self)
                    return
                }
            } else {
                self.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
                self.centerYAnchor.constraint(equalTo: parentView.centerYAnchor).isActive = true
                self.widthAnchor.constraint(equalTo: parentView.widthAnchor).isActive = true
                self.heightAnchor.constraint(equalTo: parentView.heightAnchor).isActive = true
            }
        }
    }
    
    // MARK: - Init
    public init() {
        super.init(frame: CGRect.zero)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.enbaleBackgroundGesture = false
        self.contentColor = self.isDarkMode() ? .white : .black
        self.setupViews()
        self.updateIndicators()
    }
    
    // MARK: - UI
    private func setupViews() {
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.style = .solidColor
        self.backgroundView.color = self.PPDefaultBackgroundColor
        self.addSubview(self.backgroundView)
        
        self.bezelView.layer.cornerRadius = 5.0
        self.bezelView.style = .blur
        self.bezelView.translatesAutoresizingMaskIntoConstraints = false
        self.bezelView.clipsToBounds = true
        self.bezelView.alpha = 0.0
        self.addSubview(self.bezelView)

        self.label.isOpaque = false
        self.label.textAlignment = .center
        self.label.textColor = contentColor
        self.label.font = UIFont.boldSystemFont(ofSize: PPDefaultLabelFontSize)
        self.label.backgroundColor = .clear
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.numberOfLines = 0
        self.label.lineBreakMode = .byCharWrapping
        self.bezelView.addSubview(self.label)

        self.detailLabel.isOpaque = false
        self.detailLabel.textAlignment = .center
        self.detailLabel.textColor = contentColor
        self.detailLabel.numberOfLines = 0
        self.detailLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width - CGFloat(2.0 * self.margin)
        self.detailLabel.font = UIFont.boldSystemFont(ofSize: PPDefaultDetailLabelFontSize)
        self.detailLabel.backgroundColor = .clear
        self.detailLabel.translatesAutoresizingMaskIntoConstraints = false
        self.bezelView.addSubview(self.detailLabel)

        self.button.isOpaque = false
        self.button.titleLabel?.textAlignment = .center
        self.button.titleLabel?.font = UIFont.boldSystemFont(ofSize: PPDefaultDetailLabelFontSize)
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.button.setTitleColor(self.contentColor, for: .normal)
        self.bezelView.addSubview(self.button)
    }
    
    private func updateIndicators() {
        self.indicator?.removeFromSuperview()
        self.indicator = nil
        
        if self.mode == .indeterminate {
            var activityIndicator: UIActivityIndicatorView!
            if #available(iOS 13.0, *) {
                activityIndicator = UIActivityIndicatorView(style: .large)
                activityIndicator.color = self.contentColor
            } else {
                activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
            }
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            self.bezelView.addSubview(activityIndicator)
            self.indicator = activityIndicator
        } else if self.mode == .customView {
            if let customView = self.customView {
                customView.translatesAutoresizingMaskIntoConstraints = false
                self.bezelView.addSubview(customView)
                self.indicator = customView
            }
        } else if self.mode == .determinate || self.mode == .annularDeteminate {
            let progressView = PPRoundProgressView()
            progressView.annular = self.mode == .annularDeteminate
            progressView.progressTintColor = self.contentColor
            progressView.backgroundTintColor = .lightText
            progressView.translatesAutoresizingMaskIntoConstraints = false
            self.bezelView.addSubview(progressView)
            self.indicator = progressView
        } else if self.mode == .determinateHorizontalBar {
            let barProgressView = PPBarProgressView()
            barProgressView.translatesAutoresizingMaskIntoConstraints = false
            self.bezelView.addSubview(barProgressView)
            self.indicator = barProgressView
        }
        
        self.setNeedsUpdateConstraints()
    }
    
    private func updateViewForColor() {
        self.label.textColor = self.contentColor
        self.detailLabel.textColor = self.contentColor
        self.button.setTitleColor(self.contentColor, for: .normal)
        
        if let indicator = self.indicator {
            if indicator.isKind(of: UIActivityIndicatorView.self) {
                (indicator as! UIActivityIndicatorView).color = self.contentColor
            }
        }
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        if !self.needsUpdateConstraints() {
            self.updateConstraints()
        }
        super.layoutSubviews()
    }
    
    public override func updateConstraints() {
        var subViews: [UIView] = [self.label, self.detailLabel, self.button]
        if let indicator = self.indicator {
            subViews.insert(indicator, at: 0)
        }
        
        self.bezelView.removeConstraints(self.bezelView.constraints)
        self.bezelView.updateForBackgroundStyle()
        self.backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0.0).isActive = true
        self.backgroundView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0.0).isActive = true
        self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0).isActive = true
        
        var size = CGSize.zero
        var visibleCount = 0
        for (index, view) in subViews.enumerated() {
            view.centerXAnchor.constraint(equalTo: self.bezelView.centerXAnchor).isActive = true
            if view == self.indicator {
                view.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
                view.heightAnchor.constraint(equalToConstant: view.bounds.height).isActive = true
            } else if view == self.button {
                
            } else {
                view.widthAnchor.constraint(equalTo: self.bezelView.widthAnchor, constant: -CGFloat(2 * self.margin)).isActive = true
            }
            
            if index == 0 {
                view.topAnchor.constraint(equalTo: self.bezelView.topAnchor, constant: CGFloat(self.margin)).isActive = true
            } else if index == subViews.count - 1 {
                view.bottomAnchor.constraint(equalTo: self.bezelView.bottomAnchor, constant: CGFloat(-self.margin)).isActive = true
            } else {
                let lastView = subViews[index - 1]
                view.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: CGFloat(PPDefaultPadding)).isActive = true
            }
            
            /// calculate size
            if view == self.indicator {
                size.height += view.bounds.size.height
                if view.bounds.size.width > size.width {
                    size.width = view.bounds.size.width
                }
            } else {
                size.height += view.intrinsicContentSize.height
                if view.intrinsicContentSize.width > size.width {
                    size.width = view.intrinsicContentSize.width
                }
            }
            
            if !__CGSizeEqualToSize(view.intrinsicContentSize, CGSize.zero) {
                visibleCount += 1
            }
        }
        
        if visibleCount > 1 {
            size.height += CGFloat(PPDefaultPadding * Double(visibleCount - 1))
        }
        
        size.height += CGFloat(2.0 * self.margin)
        size.width += CGFloat(2.0 * self.margin)
        size.width = min(size.width, UIScreen.main.bounds.width - CGFloat(2 * margin))
        
        self.bezelView.centerXAnchor.constraint(equalTo: self.backgroundView.centerXAnchor, constant: 0.0).isActive = true
        self.bezelView.centerYAnchor.constraint(equalTo: self.backgroundView.centerYAnchor, constant: 0.0).isActive = true
        self.bezelView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        self.bezelView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        
        super.updateConstraints()
    }
    
    // MARK: - Show & Hide
    private func showUsingAnimation(_ animation: Bool) {
        self.isShowing = true
        if animation {
            self.makeAnimate(apear: true, complete: nil)
        } else {
            self.bezelView.alpha = 1.0
        }
    }
    
    private func hideUsingAnimation(_ animation: Bool) {
        if animation {
            self.makeAnimate(apear: false) { [weak self] in
                guard let self = self else { return }
                self.finishAll()
            }
        } else {
            self.isShowing = false
            self.bezelView.alpha = 0.0
            self.finishAll()
        }
    }
    
    private func makeAnimate(apear: Bool, complete:(()->Void)?) {
        let small = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let big = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        if self.animateMode == .zoom {
            self.bezelView.alpha = 1.0
            self.bezelView.transform = apear ? small : .identity
            UIView.animate(withDuration: 0.2, animations: {
                self.bezelView.transform = apear ? .identity : small
            }) { isFinish in
                if isFinish {
                    self.bezelView.alpha = apear ? 1.0 : 0.0
                    if let complete = complete { complete() }
                }
            }
        } else if self.animateMode == .zoomOut {
            self.bezelView.alpha = 1.0
            self.bezelView.transform = apear ? small : .identity
            UIView.animate(withDuration: 0.2, animations: {
                self.bezelView.transform = apear ? .identity : big
                self.bezelView.alpha = apear ? 1.0 : 0.0
            }) { isFinish in
                if isFinish {
                    if let complete = complete { complete() }
                }
            }
        } else if self.animateMode == .zoomIn {
            self.bezelView.alpha = 1.0
            self.bezelView.transform = apear ? big : .identity
            UIView.animate(withDuration: 0.2, animations: {
                self.bezelView.transform = apear ? .identity : small
                self.bezelView.alpha = apear ? 1.0 : 0.0
            }) { isFinish in
                if isFinish {
                    if let complete = complete { complete() }
                }
            }
        } else if self.animateMode == .fadeInZoomOut {
            if apear {
                self.bezelView.alpha = 1.0
                self.bezelView.transform = .identity
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.bezelView.transform = small
                    self.bezelView.alpha = 0.2
                }) { isFinish in
                    self.bezelView.alpha = 0.0
                    complete?()
                }
            }
        } else {
            self.bezelView.alpha = apear ? 1.0 : 0.0
            complete?()
        }
    }
    
    private func finishAll() {
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 0.0
        }) { if $0 {
            if let overView = self.overParentView { overView.removeFromSuperview() }
            self.removeFromSuperview()
            }}
    }
}

// MARK: - Public

extension PPHud {
    // MARK: Show
    public class func pp_showHudActivity() -> PPHud? {
        return self.pp_showHudActivity(nil)
    }
    
    @discardableResult @objc public class func pp_showHudActivity(_ text: String?) -> PPHud? {
        return self.pp_showHudActivity(text, detail: nil, toView: nil)
    }
    
    @discardableResult @objc public class func pp_showHudActivity(_ text: String?, to view: UIView?) -> PPHud? {
        return self.pp_showHudActivity(text, detail: nil, toView: view)
    }
    
    public class func pp_showHudActivity(_ text: String?, detail: String?, toView: UIView?) -> PPHud? {
        return PPHud.pp_show(text, detail: detail, mode: .indeterminate, customView: nil, toView: toView, actionTitle: nil, target: nil, action: nil)
    }
    
    public class func pp_showProgress(_ text: String?, detail: String?) -> PPHud? {
        return self.pp_showProgress(text, detail: detail, mode: .determinate)
    }
    
    public class func pp_showProgress(_ text: String?, detail: String?, mode: PPHudMode) -> PPHud? {
        return self.pp_show(text, detail: detail, mode: mode, customView: nil, actionTitle: nil, target: nil, action: nil)
    }
    
    @discardableResult @objc public class func pp_show(_ text: String?) -> PPHud? {
        guard let hud = PPHud.pp_show(text, to: nil) else {
            return nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + 1.0)) {
            hud.hide(animated: true)
        }
        return hud
    }
    
    @discardableResult @objc public class func pp_show(_ text: String?, to view: UIView?) -> PPHud? {
        guard let hud = PPHud.pp_show(text, detail: nil, mode: .text, customView: nil, toView: view, actionTitle: nil, target: nil, action: nil) else {
            return nil
        }

        DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + 1.0)) {
            hud.hide(animated: true)
        }
        return hud
    }
    
    public class func pp_showSuccess(_ text: String?) -> PPHud? {
        let customView = UIImageView.init(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        customView.image = UIImage(named: "pp_success")
        
        guard let hud = self.pp_show(text, detail: nil, mode: .customView, customView: customView, actionTitle: nil, target: nil, action: nil) else {
            return nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + 1.0)) {
            hud.hide(animated: true)
        }
        return hud
    }
    
    public class func pp_showFail(_ text: String?) -> PPHud? {
        let customView = UIImageView.init(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        customView.image = UIImage(named: "pp_fail")
        
        guard let hud = self.pp_show(text, detail: nil, mode: .customView, customView: customView, actionTitle: nil, target: nil, action: nil) else {
            return nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + 1.0)) {
            hud.hide(animated: true)
        }
        return hud
    }
      
    public class func pp_show(_ text: String?,
                              detail: String?,
                                mode: PPHudMode,
                          customView: UIView?,
                         actionTitle: String?,
                              target: Any?,
                              action: Selector?) -> PPHud? {
        return self.pp_show(text,
                            detail: detail,
                            mode: mode,
                            customView: customView,
                            toView: nil,
                            actionTitle: actionTitle,
                            target: target,
                            action: action)
    }
    
    public class func pp_show(_ text: String?,
                              detail: String?,
                                mode: PPHudMode,
                          customView: UIView?,
                              toView: UIView?,
                         actionTitle: String?,
                              target: Any?,
                              action: Selector?) -> PPHud? {
        guard let window = UIApplication.shared.delegate?.window as? UIView else { return nil }
        let hud = PPHud.pp_showHudTo(view: toView ?? window, animated: true)
        hud.mode = mode
        hud.text = text
        hud.detail = detail
        
        if let customView = customView, mode == .customView {
            hud.customView = customView
        }
        
        if let actionTitle = actionTitle, let target = target, let action = action {
            hud.button.setTitle(actionTitle, for: .normal)
            hud.button.addTarget(target, action: action, for: .touchUpInside)
        }
        
        return hud
    }
    
    // MARK: Base
    public class func pp_showHudTo(view: UIView!, animated: Bool) -> PPHud {
        let hud = PPHud()
        view.addSubview(hud)
        hud.showUsingAnimation(animated)
        return hud
    }
    
    // MARK: Hide
    @objc public func hide() {
        self.hide(animated: true)
    }
    
    public func hide(animated: Bool) {
        assert(Thread.isMainThread, "PPHud needs to be accessed on the main thread.")
        if !self.isShowing {
            return
        }
        
        self.hideUsingAnimation(animated)
    }
    
    public class func pp_hud() -> PPHud? {
        guard let window = UIApplication.shared.delegate?.window else { return nil }
        
        return self.pp_hudFor(view: window!)
    }
    
    public class func pp_hudFor(view: UIView) -> PPHud? {
        var result: PPHud?
        
        for view in view.subviews {
            if view.isKind(of: PPHud.self) {
                if (view as! PPHud).isShowing {
                    result = view as? PPHud
                }
            }
        }
        
        return result
    }
    
    // MARK: - Private
    
    /// 判断是否深色模式
    /// - Returns: 是否深色模式
    private func isDarkMode() -> Bool {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        } else {
            return false
        }
    }
}

// MARK: - BackgroundView

public enum PPHudBackgroundStyle {
    case blur
    case solidColor
}

public class PPBackgroundView: UIView {
    private var effectView: UIVisualEffectView?
    public var style: PPHudBackgroundStyle = .solidColor {
        willSet {
            if newValue != self.style {
                self.style = newValue
                self.updateForBackgroundStyle()
            }
        }
    }
    var blurEffectStyle: UIBlurEffect.Style = .extraLight {
        willSet {
            if newValue != self.blurEffectStyle {
                self.blurEffectStyle = newValue
                self.updateForBackgroundStyle()
            }
        }
    }
    public var color: UIColor? = .clear {
        willSet {
            if newValue != self.color {
                self.color = newValue
                self.style = .solidColor
                self.updateForBackgroundStyle()
            }
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            self.blurEffectStyle = .systemThickMaterial
        } else {
            self.blurEffectStyle = .light
            self.color = UIColor.init(white: 0.8, alpha: 0.6)
        }
        self.updateForBackgroundStyle()
    }
    
    open func updateForBackgroundStyle() {
        self.effectView?.removeFromSuperview()
        self.effectView = nil
        
        if self.style == .blur {
            let effect = UIBlurEffect(style: self.blurEffectStyle)
            let effectView = UIVisualEffectView(effect: effect)
            effectView.translatesAutoresizingMaskIntoConstraints = false
            self.insertSubview(effectView, at: 0)
            effectView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            effectView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            effectView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            effectView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            self.backgroundColor = self.color
            self.layer.allowsGroupOpacity = false
            self.effectView = effectView
        } else {
            self.backgroundColor = self.color
            self.alpha = 0.0
            UIView.animate(withDuration: 0.1) {
                self.alpha = 1.0
            }
        }
    }
    
    func updateViewsForColor(_ color: UIColor!) {
        if self.style == .blur {
            self.backgroundColor = self.color
        } else {
            self.backgroundColor = self.color
        }
    }
}

// MARK: - progress
class PPRoundProgressView: UIView {
    var progress: CGFloat = 0.0 {
        willSet {
            if newValue != self.progress {
                self.progress = newValue
                self.setNeedsDisplay()
            }
        }
    }
    
    var progressTintColor: UIColor = .white
    var backgroundTintColor : UIColor = .white
    
    var annular = false
    
    init() {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 37.0, height: 37.0))
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.backgroundColor = .clear
        self.isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        if (self.annular) {
            // Draw background
            let lineWidth: CGFloat = 2.0
            let processBackgroundPath = UIBezierPath()
            processBackgroundPath.lineWidth = lineWidth
            processBackgroundPath.lineCapStyle = .butt
            
            
            let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            let radius = (self.bounds.size.width - lineWidth) / 2.0
            let startAngle = CGFloat(-.pi / 2.0)
            var endAngle = CGFloat((2 * .pi) + startAngle)
            processBackgroundPath.addArc(withCenter: center,
                                         radius: radius,
                                         startAngle: startAngle,
                                         endAngle: endAngle,
                                         clockwise: true)
            
            self.backgroundTintColor.set()
            processBackgroundPath.stroke()
            // Draw progress
            let processPath = UIBezierPath()
            processPath.lineCapStyle = .square
            processPath.lineWidth = lineWidth
            endAngle = self.progress * 2 * .pi + startAngle
            processPath.addArc(withCenter: center,
                               radius: radius,
                               startAngle: startAngle,
                               endAngle: endAngle,
                               clockwise: true)
            self.progressTintColor.set()
            processPath.stroke()
        } else {
            // Draw background
            let lineWidth: CGFloat = 2.0
            let allRect = self.bounds
            let circleRect = allRect.insetBy(dx: lineWidth/2.0, dy: lineWidth/2.0)
            let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            self.progressTintColor.setStroke()
            self.backgroundTintColor.setFill()
            context?.setLineWidth(lineWidth)
            context?.strokeEllipse(in: circleRect)
            // 90 degrees
            let startAngle = CGFloat(-(.pi / 2.0))
            // Draw progress
            let processPath = UIBezierPath()
            processPath.lineCapStyle = .butt
            processPath.lineWidth = lineWidth * 2.0
            
            let radius = self.bounds.width / 2.0 - processPath.lineWidth / 2.0
            let endAngle = (self.progress * 2.0 * .pi) + startAngle
            processPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            // Ensure that we don't get color overlapping when _progressTintColor alpha < 1.f.
            context?.setBlendMode(.copy)
            self.progressTintColor.set()
            processPath.stroke()
        }
    }
}

// MARK: - Bar Progress
class PPBarProgressView: UIView {
    var progress: CGFloat = 0.0 {
        willSet {
            if newValue != self.progress {
                self.progress = newValue
                self.setNeedsDisplay()
            }
        }
    }
    
    var lineColor: UIColor = .black {
        willSet {
            if newValue != self.lineColor {
                self.lineColor = newValue
                self.setNeedsDisplay()
            }
        }
    }
    var progressRemainingColor: UIColor = .white {
        willSet {
            if newValue != self.progressRemainingColor {
                self.progressRemainingColor = newValue
                self.setNeedsDisplay()
            }
        }
    }
    var progressColor: UIColor = .lightGray {
        willSet {
            if newValue != self.progressColor {
                self.progressColor = newValue
                self.setNeedsDisplay()
            }
        }
    }
    
    init() {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 120.0, height: 20.0))
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.backgroundColor = .clear
        self.isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context?.setLineWidth(2.0)
        context?.setStrokeColor(self.lineColor.cgColor)
        context?.setFillColor(self.progressRemainingColor.cgColor)
        
        // Draw background and Border
        var radius = (rect.size.height / 2) - 2
        context?.move(to: CGPoint(x: 2.0, y: rect.size.height/2))
        context?.addArc(tangent1End: CGPoint(x: 2.0, y: 2.0),
                        tangent2End: CGPoint(x: radius + 2.0, y: 2.0),
                        radius: radius)
        context?.addArc(tangent1End: CGPoint(x: rect.size.width - 2.0, y: 2.0),
                        tangent2End: CGPoint(x: rect.size.width - 2.0, y: rect.size.height / 2.0),
                        radius: radius)
        context?.addArc(tangent1End: CGPoint(x: rect.size.width - 2.0, y: rect.size.height - 2.0),
                        tangent2End: CGPoint(x: rect.size.width - radius - 2.0, y: rect.size.height - 2.0),
                        radius: radius)
        context?.addArc(tangent1End: CGPoint(x: 2.0, y: rect.size.height - 2.0),
                        tangent2End: CGPoint(x: 2.0, y: rect.size.height / 2.0),
                        radius: radius)
        context?.drawPath(using: .fillStroke)
        context?.setFillColor(self.progressColor.cgColor)
        radius -= 2.0
        let amount = self.progress * rect.size.width;

        // Progress in the middle area
        if (amount >= radius + 4) && (amount <= (rect.size.width - radius - 4.0)) {
            context?.move(to: CGPoint(x: 4.0, y: rect.size.height / 2.0))
            context?.addArc(tangent1End: CGPoint(x: 4.0, y: 4.0),
                            tangent2End: CGPoint(x: radius + 4.0, y: 4.0),
                            radius: radius)
            context?.addLine(to: CGPoint(x: amount, y: 4.0))
            context?.addLine(to: CGPoint(x: amount, y: radius + 4.0))
            context?.move(to: CGPoint(x: 4.0, y: rect.size.height / 2.0))
            context?.addArc(tangent1End: CGPoint(x: 4.0, y: rect.size.height - 4.0),
                            tangent2End: CGPoint(x: radius + 4.0, y: rect.size.height - 4.0),
                            radius: radius)
            context?.addLine(to: CGPoint(x: amount, y: rect.size.height - 4.0))
            context?.addLine(to: CGPoint(x: amount, y: radius + 4.0))
            context?.fillPath()
        }

        // Progress in the right arc
        else if (amount > radius + 4) {
            let x = amount - (rect.size.width - radius - 4.0)

            context?.move(to: CGPoint(x: 4.0, y: rect.size.height / 2.0))
            context?.addArc(tangent1End: CGPoint(x: 4.0, y: 4.0),
                            tangent2End: CGPoint(x: radius + 4.0, y: 4.0),
                            radius: radius)
            context?.addLine(to: CGPoint(x: rect.size.width - radius - 4.0, y: 4.0))
            var angle = -acos(x / radius)
            if angle.isNaN { angle = 0 }
            context?.addArc(center: CGPoint(x: rect.size.width - radius - 4.0, y: rect.size.height / 2.0),
                            radius: radius,
                            startAngle: .pi,
                            endAngle: angle,
                            clockwise: false)
            context?.addLine(to: CGPoint(x: amount, y: rect.size.height / 2.0))
            context?.move(to: CGPoint(x: 4.0, y: rect.size.height / 2.0))
            context?.addArc(tangent1End: CGPoint(x: 4.0, y: rect.size.height - 4.0),
                            tangent2End: CGPoint(x: radius + 4.0, y: rect.size.height - 4.0),
                            radius: radius)
            context?.addLine(to: CGPoint(x: rect.size.width - radius - 4.0, y: rect.size.height - 4.0))
            angle = acos(x/radius)
            if angle.isNaN { angle = 0 }
            context?.addArc(center: CGPoint(x: rect.size.width - radius - 4, y: rect.size.height/2),
                            radius: radius,
                            startAngle: -.pi,
                            endAngle: angle,
                            clockwise: true)
            context?.addLine(to: CGPoint(x: amount, y: rect.size.height / 2.0))
            context?.fillPath()
        }

        // Progress is in the left arc
        else if (amount < radius + 4.0) && amount > 0 {
            context?.move(to: CGPoint(x: 4.0, y: rect.size.height / 2.0))
            context?.addArc(tangent1End: CGPoint(x: 4.0, y: 4.0),
                            tangent2End: CGPoint(x: radius + 4.0, y: 4.0),
                            radius: radius)
            context?.addLine(to: CGPoint(x: radius + 4.0, y: rect.height / 2.0))
            context?.move(to: CGPoint(x: 4.0, y: rect.height / 2.0))
            context?.addArc(tangent1End: CGPoint(x: 4.0, y: rect.height - 4.0),
                            tangent2End: CGPoint(x: radius + 4.0, y: rect.size.height - 4.0),
                            radius: radius)
            context?.addLine(to: CGPoint(x: radius + 4.0, y: rect.height / 2.0))
            context?.fillPath()
        }
    }
}

class PPHudRoundButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 1.0;
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        self.layer.cornerRadius = ceil(self.bounds.height / 2.0)
        super.updateConstraints()
    }

    override var intrinsicContentSize: CGSize {
        if self.allControlEvents.rawValue == 0 || self.title(for: .normal)?.count == 0 {
            return .zero
        }
        var size = super.intrinsicContentSize
        size.width += 20.0
        return size
    }
    
    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        self.layer.borderColor = color?.cgColor
    }

    override var isHighlighted: Bool {
        didSet {
            let baseColor = self.titleColor(for: .selected)
            self.backgroundColor = self.isHighlighted ? baseColor?.withAlphaComponent(0.1) : .clear
        }
    }
}
