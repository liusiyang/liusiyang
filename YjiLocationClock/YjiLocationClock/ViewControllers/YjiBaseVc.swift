//
//  YjiBaseVc.swift
//  YjiPhotoViewer
//
//  Created by jiyun on 2016/03/07.
//  Copyright © 2016年 Ericji. All rights reserved.
//

import UIKit

class YjiBaseVc: UIViewController {
    
    var mModalView: UIView?
    var mLoadingView: UIView?
    var mIndicator: UIActivityIndicatorView?
    
    var mHideNaviBar = false {
        willSet {
            self.hideNaviBar(newValue)
        }
    }
    
    var mTitle: String? {
        willSet {
            self.setCustomTitle(newValue!)
        }
    }
    
    var mBackBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 25))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navi bar defalut
        self.hideNaviBar(mHideNaviBar)
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        
        // setぐるぐる画面
        mModalView = UIView.init(frame: self.view.bounds)
        mModalView?.backgroundColor = UIColor.clear // to protect user from handling
        mLoadingView = UIView.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        mLoadingView?.center = CGPoint(x: YjiComFuncs.getScreenWidth() / 2, y: YjiComFuncs.getScreenHeight() / 2)
        mLoadingView!.backgroundColor = UIColor.gray
        mLoadingView!.alpha = 1
        mLoadingView?.cornerRadius = 10
        
        mIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        mIndicator!.center = CGPoint(x: mLoadingView!.bounds.size.width / 2, y: mLoadingView!.bounds.size.height / 2)
        mLoadingView!.addSubview(mIndicator!)
        mModalView!.addSubview(mLoadingView!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func hideNaviBar(_ isNeed: Bool) {
        self.navigationController?.navigationBar.isHidden = isNeed
    }
    
    func setCustomTitle(_ titleStr: String) {
        let titLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        titLbl.text = titleStr
        titLbl.textAlignment = .center
        titLbl.textColor = UIColor.white
        titLbl.font = UIFont.boldSystemFont(ofSize: 18)
        self.navigationItem.titleView = titLbl
    }
    
    func popViewController(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - ぐるぐる画面表示
    func showProgressView() {
        self.view.addSubview(mModalView!)
        mIndicator?.startAnimating()
    }
    
    func stopProgressView() {
        mModalView?.removeFromSuperview()
        mIndicator?.stopAnimating()
    }

    // alert
    func showAlertWith(_ title: String, msg: String) {
        if self.presentedViewController == nil {
            let av = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            av.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                print("User select the OK button")
                if self is YjiGMapSearchVc {
                    (self as! YjiGMapSearchVc).cancelMonitor()
                } else {
                    YjiLocationManager.sharedInstance.stopUpdateLocation()
                }
            }))
            self.present(av, animated: true, completion: nil)
        }
    }

}
