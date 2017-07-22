//
//  ViewController.swift
//  YjiLocationClock
//
//  Created by 季云 on 16/3/27.
//  Copyright © 2016年 yji. All rights reserved.
//

import UIKit
import SnapKit

class YjiStartVc: YjiBaseVc {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.mTitle = "ようこそ"
        
        // background image
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "startView")
        self.view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }

        let startBtn = TKTransitionSubmitButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 64, height: 44))
        startBtn.cornerRadius = 10
        startBtn.backgroundColor = UIColor.black
        startBtn.center = self.view.center
        startBtn.frame.bottom = self.view.frame.height - 60
        startBtn.setTitle("始める", for: UIControlState())
        startBtn.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        startBtn.addTarget(self, action: #selector(self.startAction(btn:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(startBtn)
    }
    
    func startAction(btn: TKTransitionSubmitButton) {
        btn.animate(0.5, completion: { [weak self] () -> () in
            UserDefaults.standard.set(true, forKey: "login")
            UserDefaults.standard.synchronize()
            let vc = YjiGMapSearchVc()
            self?.navigationController?.pushViewController(vc, animated: true)
        })

    }
    
    // MARK: UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TKFadeInAnimator(transitionDuration: 0.5, startingAlpha: 0.8)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }


}

