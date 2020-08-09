//
//  PPHudWrapper.swift
//  PPHud
//
//  Created by Alex on 2020/8/7.
//

import Foundation
import UIKit

public final class PPHudWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol PPHudCompatible {}

public extension PPHudCompatible {
    var pp: PPHudWrapper<Self> {
        get { return PPHudWrapper(self) }
        set { }
    }
}

extension UIView: PPHudCompatible { }

extension PPHudWrapper where Base == UIView {
    
    public func hud() -> PPHud? {
        return PPHud.pp_hudFor(view: self.base)
    }
    
    public func dismissHud() {
        guard let hud = PPHud.pp_hudFor(view: self.base) else { return }
        
        hud.hide(animated: true)
    }
    
    // MARK: - Indeterminate
    public func showActivity() -> PPHud? {
        return self.showActivity(nil)
    }
    
    public func showActivity(_ text: String?) -> PPHud? {
        return self.showActivity(text: text, detail: nil)
    }
    
    public func showActivity(text: String?, detail: String?) -> PPHud? {
        return self.showActivity(text: text, detail: detail, color: nil)
    }
    
    public func showActivity(text: String?,
                             detail: String?,
                             color: UIColor?) -> PPHud? {
        let hud = PPHud.pp_showHudTo(view: self.base, animated: true)
        hud.label.text = text
        hud.detailLabel.text = detail
        hud.contentColor = color ?? .black
        return hud
    }
    
    // MARK: - Determinate
    public func showProgress(_ text: String) -> PPHud? {
        return self.showProgress(text: text, mode: .determinate)
    }
    
    public func showProgress(text: String, mode: PPHudMode) -> PPHud? {
        let hud = PPHud.pp_showHudTo(view: self.base, animated: true)
        hud.label.text = text
        hud.mode = mode
        return hud
    }
    
    public func showHudAction(text: String,
                              mode: PPHudMode,
                              actionTile: String,
                              target: Any?,
                              action: Selector) -> PPHud? {
        let hud = PPHud.pp_showHudTo(view: self.base, animated: true)
        hud.label.text = text
        hud.mode = mode
        hud.button.setTitle(actionTile, for: .normal)
        hud.button.addTarget(target, action: action, for: .touchUpInside)
        return hud
    }
    
    public func updateProgress(_ progress: CGFloat) -> PPHud? {
        guard let hud = PPHud.pp_hudFor(view: self.base),
              hud.mode == .determinate ||
                hud.mode == .annularDeteminate ||
                hud.mode == .determinateHorizontalBar else {
            return nil
        }
        hud.propress = progress
        return hud
    }
    
    // MARK: - Text
    public func showText(_ text: String) -> PPHud? {
        return self.showText(text, autoHide: true)
    }
    
    public func showText(_ text: String, autoHide: Bool) -> PPHud? {
        let hud = PPHud.pp_showHudTo(view: self.base, animated: true)
        hud.mode = .text
        hud.label.text = text
        if autoHide { hud.hide(animated: true, after: 2.0) }
        return hud
    }
    
    // MARK: - Custom Image
    public func showSuccess(_ text: String) -> PPHud? {
        let hud = PPHud.pp_showHudTo(view: self.base, animated: true)
        hud.mode = .customView
        
        let customView = UIImageView.init(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        customView.image = UIImage(named: "pp_success")
        hud.customView = customView
        hud.label.text = text
        
        hud.hide(animated: true, after: 2.0)
        return hud
    }
}
