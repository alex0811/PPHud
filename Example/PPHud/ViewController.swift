//
//  ViewController.swift
//  PPHud
//
//  Created by alex0811 on 06/14/2020.
//  Copyright (c) 2020 alex0811. All rights reserved.
//

import UIKit
import PPHud

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var dataList: Array<Array<PPAction>>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Init
    private func commonInit() {
        self.title = "PPHud"
        self.dataList = [
            [
                PPAction(actionTitle: "Indeterminate Mode", actionSel: #selector(ViewController.indeterminateModelAction)),
                PPAction(actionTitle: "With label", actionSel: #selector(ViewController.indeterminateWithLabelModeAction)),
                PPAction(actionTitle: "With details label", actionSel: #selector(ViewController.indeterminateWithDetailLabelModeAction)),
            ],
            [
                PPAction(actionTitle: "Determinate mode", actionSel: #selector(ViewController.determinateModeAction)),
                PPAction(actionTitle: "Aunular determinate mode", actionSel: #selector(ViewController.aunularDeterminateModeAction)),
                PPAction(actionTitle: "Bar determinate mode", actionSel: #selector(ViewController.barDeterminateModeAction)),
            ],
            [
                PPAction(actionTitle: "Text only", actionSel: #selector(ViewController.textOnlyModeAction)),
                PPAction(actionTitle: "Custom view", actionSel: #selector(ViewController.customViewModeAction)),
                PPAction(actionTitle: "With action button", actionSel: #selector(ViewController.actionButtonModeAction)),
                PPAction(actionTitle: "Mode switching", actionSel: #selector(ViewController.switchingModeAction)),
            ],
            [
                PPAction(actionTitle: "Window", actionSel: #selector(ViewController.windowAction)),
                PPAction(actionTitle: "Dim background", actionSel: #selector(ViewController.dimBackgrounAction)),
                PPAction(actionTitle: "Action background", actionSel: #selector(ViewController.doBackgrounAction)),
                PPAction(actionTitle: "Colored", actionSel: #selector(ViewController.colordAction)),
            ],
            [
                PPAction(actionTitle: "Center absolute scrollView ", actionSel: #selector(ViewController.centerAbsoluteScrollViewAction)),
                PPAction(actionTitle: "Center compare scrollView ", actionSel: #selector(ViewController.centerCompareScrollViewAction)),
            ],
        ]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }

    // MARK: - Actions
    @objc private func indeterminateModelAction() {
        let hud = PPHud.pp_showHudTo(view: self.view, animated: true)
        DispatchQueue.global().async {
            // do your work
            DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + 1.0)) {
                hud.hide(animated: true)
            }
        }
    }
    
    @objc private func indeterminateWithLabelModeAction() {
        let hud = PPHud.pp_showHudTo(view: self.view, animated: true)
        hud.label.text = "Loading..."
        DispatchQueue.global().async {
            // do your work
            DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + 3.0)) {
                hud.hide(animated: true)
            }
        }
    }
    
    @objc private func indeterminateWithDetailLabelModeAction() {
        let hud = PPHud.pp_showHudTo(view: self.view, animated: true)
        hud.label.text = "Loading..."
        hud.detailLabel.text = "download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...\n(1/3)"
        DispatchQueue.global().async {
            // do your work
            DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + 3.0)) {
                hud.hide(animated: true)
            }
        }
    }
    
    // MARK: -
    @objc private func determinateModeAction() {
        let hud = PPHud.pp_showHudTo(view: self.view, animated: true)
        hud.label.text = "Loading..."
        hud.mode = .determinate
        
        var progress: CGFloat = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            progress += 0.1
            if progress <= 1.0 {
                DispatchQueue.main.async {
                    hud.propress = progress
                }
            } else {
                timer.invalidate()
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                }
            }
        }
        timer.fire()
    }
    
    @objc private func aunularDeterminateModeAction() {
        let hud = PPHud.pp_showHudTo(view: self.view, animated: true)
        hud.label.text = "Loading..."
        hud.mode = .annularDeteminate
        
        var progress: CGFloat = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            progress += 0.1
            if progress <= 1.0 {
                DispatchQueue.main.async {
                    hud.propress = progress
                }
            } else {
                timer.invalidate()
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                }
            }
        }
        timer.fire()
    }
    
    @objc private func barDeterminateModeAction() {
        let hud = PPHud.pp_showHudTo(view: self.view, animated: true)
        hud.label.text = "Loading..."
        hud.mode = .determinateHorizontalBar
        
        var progress: CGFloat = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            progress += 0.1
            if progress <= 1.0 {
                DispatchQueue.main.async {
                    hud.propress = progress
                }
            } else {
                timer.invalidate()
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                }
            }
        }
        timer.fire()
    }
    
    @objc private func textOnlyModeAction() {
        let hud = PPHud.pp_showHudTo(view: self.view, animated: true)
        hud.mode = .text
        hud.label.text = "Hello PPHud!"
        hud.hide(animated: true, after: 2.0)
    }
    
    @objc private func customViewModeAction() {
        let hud = PPHud.pp_showHudTo(view: self.view, animated: true)
        hud.mode = .customView
        
        let customView = UIImageView.init(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        customView.image = UIImage(named: "pp_success")
        hud.customView = customView
        hud.label.text = "success!"
        
        hud.hide(animated: true, after: 2.0)
    }
    
    @objc private func actionButtonModeAction() {
        let hud = PPHud.pp_showHudTo(view: self.view, animated: true)
        hud.label.text = "Loading..."
        hud.mode = .determinateHorizontalBar
        hud.button.setTitle("cancel", for: .normal)
        hud.button.addTarget(self, action: #selector(ViewController.cancelAction), for: .touchUpInside)
        var progress: CGFloat = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            progress += 0.1
            if progress <= 1.0 {
                DispatchQueue.main.async {
                    hud.propress = progress
                }
            } else {
                timer.invalidate()
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                }
            }
        }
        timer.fire()
    }
    
    @objc private func cancelAction() {
        if let hud = PPHud.pp_hudFor(view: self.view) {
            hud.hide(animated: true)
        }
    }
    
    @objc private func switchingModeAction() {
        let hud = PPHud.pp_showHudTo(view: self.view, animated: true)
        hud.label.text = "prepare..."
        hud.mode = .text
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            hud.mode = .indeterminate
            hud.label.text = "uploading..."
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6.0) {
            hud.mode = .text
            hud.label.text = "done!"
            hud.hide(animated: true, after: 1.0)
        }
    }
    
    // MARK: -
    @objc private func windowAction() {
        if let window = UIApplication.shared.delegate?.window {
            let hud = PPHud.pp_showHudTo(view: window, animated: true)
            hud.animateMode = .zoomIn
            hud.mode = .indeterminate
            hud.backgroundView.style = .solidColor
            hud.backgroundView.color = UIColor.init(white: 0.0, alpha: 0.1)
            hud.hide(animated: true, after: 2.0)
        }
    }
    
    @objc private func dimBackgrounAction() {
        let hud = PPHud.pp_showHudTo(view: self.view, animated: true)
        hud.animateMode = .zoomIn
        hud.mode = .indeterminate
        hud.backgroundView.style = .solidColor
        hud.backgroundView.color = UIColor.init(white: 0.0, alpha: 0.1)
        hud.hide(animated: true, after: 2.0)
    }
    
    @objc private func doBackgrounAction() {
        let hud = PPHud.pp_showHudTo(view: self.view, animated: true)
        hud.mode = .indeterminate
        hud.backgroundView.color = UIColor.init(white: 0.0, alpha: 0.1)
        hud.hide(animated: true, after: 2.0)
        hud.enbaleBackgroundGesture = true
    }
    
    @objc private func colordAction() {
        let hud = PPHud.pp_showHudTo(view: self.view, animated: true)
        hud.animateMode = .zoomIn
        hud.mode = .indeterminate
        hud.label.text = "Loading..."
        hud.contentColor = .purple
        hud.hide(animated: true, after: 2.0)
    }
    
    // MARK: -
    @objc private func centerAbsoluteScrollViewAction() {
        let hud = PPHud.pp_showHudTo(view: self.tableView, animated: true)
        hud.mode = .indeterminate
        hud.backgroundView.color = UIColor.init(white: 0.0, alpha: 0.1)
        hud.hide(animated: true, after: 2.0)
    }
    
    @objc private func centerCompareScrollViewAction() {
        let hud = PPHud.pp_showHudTo(view: self.tableView, animated: true)
        hud.mode = .indeterminate
        hud.backgroundView.color = UIColor.init(white: 0.0, alpha: 0.1)
        hud.enbaleBackgroundGesture = true
        hud.hide(animated: true, after: 2.0)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self)) else {
            return UITableViewCell()
        }
        cell.textLabel?.textColor = self.view.tintColor
        cell.textLabel?.text = dataList[indexPath.section][indexPath.row].title as String?
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.perform(dataList[indexPath.section][indexPath.row].sel)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class PPAction: NSObject {
    var title: NSString!
    var sel: Selector!
    
    init(actionTitle: NSString!, actionSel: Selector!) {
        title = actionTitle
        sel = actionSel
    }
}

