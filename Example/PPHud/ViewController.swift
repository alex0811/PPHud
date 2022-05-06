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
                PPAction(actionTitle: "Center absolute scrollView ", actionSel: #selector(ViewController.centerScrollViewAction)),
            ],
        ]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }

    // MARK: - Actions
    @objc private func indeterminateModelAction() {
//        guard let hud = PPHud.pp_showHudActivity() else {
//            return
//        }
        guard let hud = self.view.pp.showActivity() else {
            return
        }
        
        DispatchQueue.global().async {
            // do your work
            DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + 1.0)) {
                hud.hide()
            }
        }
    }
    
    @objc private func indeterminateWithLabelModeAction() {
//        guard let hud = PPHud.pp_showHudActivity("Loading...") else {
//            return
//        }
        
        guard let hud = self.view.pp.showActivity("Loading...") else {
            return
        }
        
        DispatchQueue.global().async {
            // do your work
            DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + 3.0)) {
                hud.hide()
            }
        }
    }
    
    @objc private func indeterminateWithDetailLabelModeAction() {
        let detail = "download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...download images...\n(1/3)"
        
//        guard let hude = PPHud.pp_showHudActivity("Loading...", detail: detail) else {
//            return
//        }
        
        guard let hude = self.view.pp.showActivity(text: "Loading...", detail: detail) else {
            return
        }
        
        DispatchQueue.global().async {
            // do your work
            DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + 3.0)) {
                hude.hide()
            }
        }
    }
    
    // MARK: -
    @objc private func determinateModeAction() {
//        guard let hud = PPHud.pp_showProgress("Loading...", detail: "step(1/10)") else { return }
        guard let hud = self.view.pp.showProgress(text: "Loading...", detail: "step(1/10)", mode: .indeterminate) else { return }
        
        var progress: CGFloat = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            progress += 1
            if progress <= 10 {
                DispatchQueue.main.async {
                    hud.propress = progress / 10.0
                    hud.detail = String(format: "step(%.f/10)", progress)
                }
            } else {
                timer.invalidate()
                DispatchQueue.main.async {
                    hud.hide()
                }
            }
        }
        timer.fire()
    }
    
    @objc private func aunularDeterminateModeAction() {
//        guard let hud = PPHud.pp_showProgress("Loading...", detail: nil, mode: .annularDeteminate) else {
//            return
//        }
        guard let hud = self.view.pp.showProgress(text: "Loading...", detail: nil, mode: .annularDeteminate) else { return }
        
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
                    hud.hide()
                }
            }
        }
        timer.fire()
    }
    
    @objc private func barDeterminateModeAction() {
//        guard let hud = PPHud.pp_showProgress("Loading...", detail: "soon", mode: .determinateHorizontalBar) else {
//            return
//        }
        guard let hud = self.view.pp.showProgress(text: "Loading...", detail: nil, mode: .determinateHorizontalBar) else { return }
        
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
                    hud.hide()
                }
            }
        }
        timer.fire()
    }
    
    @objc private func textOnlyModeAction() {
//        let _ = PPHud.pp_show("Hello Swift")
        let _ = self.view.pp.showText("Hello Swift")
    }
    
    @objc private func customViewModeAction() {
//        let _ = PPHud.pp_showSuccess("成功")
//        let _ = PPHud.pp_showFail("出错啦！")
        
        let _ = self.view.pp.pp_showFail(("失败"))
    }
    
    @objc private func actionButtonModeAction() {
//        guard let hud = PPHud.pp_show("Loading...", detail: nil, mode: .determinateHorizontalBar, customView: nil, actionTitle: "cancel", target: self, action: #selector(ViewController.cancelAction)) else {
//            return
//        }
        
        guard let hud = self.view.pp.showHudAction(text: "Loading...", mode: .determinateHorizontalBar, actionTile: "cancel", target: self, action: #selector(ViewController.cancelAction)) else {
            return
        }
        
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
                    hud.hide()
                }
            }
        }
        timer.fire()
    }
    
    @objc private func cancelAction() {
//        if let hud = PPHud.pp_hud() {
//            hud.hide()
//        }
        
        self.view.pp.dismissHud()
    }
    
    @objc private func switchingModeAction() {
        guard let hud = self.view.pp.showHud() else {
            return
        }
//        guard let hud = PPHud.pp_showHudActivity() else {
//            return
//        }
        hud.label.text = "prepare..."
        hud.mode = .text
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            hud.mode = .indeterminate
            hud.label.text = "uploading..."
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6.0) {
            hud.mode = .text
            hud.label.text = "done!"
            hud.hide(animated: true)
        }
    }
    
    // MARK: -
    @objc private func windowAction() {
        guard let hud = PPHud.pp_showHudActivity() else {
            return
        }
        
        hud.animateMode = .zoomIn
        hud.hide(animated: true)
    }
    
    @objc private func dimBackgrounAction() {
        guard let hud = PPHud.pp_showHudActivity() else {
            return
        }
        
        hud.animateMode = .zoomIn
        hud.hide(animated: true)
    }
    
    @objc private func doBackgrounAction() {
        guard let hud = PPHud.pp_showHudActivity() else {
            return
        }
        
        hud.enbaleBackgroundGesture = true
        hud.animateMode = .zoomIn
        hud.hide(animated: true)
    }
    
    @objc private func colordAction() {
        guard let hud = PPHud.pp_showHudActivity() else {
            return
        }
        
        hud.text = "Loading..."
        hud.contentColor = .purple
        hud.hide(animated: true)
    }
    
    // MARK: -
    @objc private func centerScrollViewAction() {
        let hud = PPHud.pp_showHudTo(view: self.tableView, animated: true)
        hud.mode = .indeterminate
        hud.backgroundView.color = UIColor.init(white: 0.0, alpha: 0.1)
        hud.hide(animated: true)
        hud.enbaleBackgroundGesture = true
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

