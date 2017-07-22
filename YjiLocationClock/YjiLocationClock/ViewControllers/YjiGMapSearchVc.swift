//
//  QVSGMapViewController.swift
//  Monaca
//
//  Created by kiu-cts on 2016/02/12.
//  Copyright © 2016年 CASIO. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import GoogleMaps
import EasyTipView
import GooglePlaces

class YjiGMapSearchVc: YjiBaseVc, CLLocationManagerDelegate, GMSMapViewDelegate, UISearchBarDelegate {
    let mSlider = UISlider()
    var mGmaps = GMSMapView()
    var mYjiLocationManager: YjiLocationManager?
    var mCurrentLocation: CLLocation?
    var mDidFindMyLocation = false
    var mLocationMarker = GMSMarker()
    var mSelectedPosition = CLLocationCoordinate2D()
    var mSelectedLocation: CLLocation?
    var mCircle =  GMSCircle()
    var mPreferences = EasyTipView.globalPreferences
    let curLocation = UILabel()
    let distanceLbl = UILabel()
    
    // 1.2
    var mResultsViewController: GMSAutocompleteResultsViewController?
    var mSearchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mTitle = "地図"
        
        // right UIBarButtonItem
        let createBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        createBtn.setTitle("監視", for: UIControlState())
        createBtn.setTitleColor(UIColor.white, for: UIControlState())
        createBtn.addTarget(self, action:#selector(self.startMonitor), for: .touchUpInside)
        let cBarButtonItem = UIBarButtonItem(customView: createBtn)
        self.navigationItem.setRightBarButton(cBarButtonItem, animated: true)
        
        let cancelBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        cancelBtn.setTitle("停止", for: UIControlState())
        cancelBtn.setTitleColor(UIColor.white, for: UIControlState())
        cancelBtn.addTarget(self, action:#selector(self.cancelMonitor), for: .touchUpInside)
        let cancelBarButtonItem = UIBarButtonItem(customView: cancelBtn)
        self.navigationItem.setLeftBarButton(cancelBarButtonItem, animated: true)
        
        mYjiLocationManager = YjiLocationManager.sharedInstance
        NotificationCenter.default.addObserver(self, selector: #selector(self.getAuthorizaion(_:)), name: NSNotification.Name(rawValue: notificationGpsAuthorizaionGet), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateLocation(_:)), name: NSNotification.Name(rawValue: notificationUpdateLocation), object: nil)
        
        
        // Do any additional setup after loading the view.
        self.view.addSubview(mGmaps)
        mGmaps.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 48.857165, longitude: 2.354613, zoom: 8.0)
        mGmaps.camera = camera
        // MapViewをviewに追加する.
        mGmaps.isMyLocationEnabled = true
        mGmaps.delegate = self
        mGmaps.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        // help button layout setting
        let helpBtn = UIButton()
        helpBtn.addTarget(self, action: #selector(self.launchHelpTip(btn:)), for: .touchUpInside)
        helpBtn.setImage(UIImage(named: "help_icon"), for: UIControlState())
        self.view.addSubview(helpBtn)
        helpBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.bottom.equalTo(-20)
            make.centerX.equalToSuperview()
        }
        
        // help button preference setting
        mPreferences.drawing.arrowPosition = .bottom
        mPreferences.drawing.font = UIFont.systemFont(ofSize: 14)
        mPreferences.drawing.textAlignment = .center
        mPreferences.drawing.backgroundColor = UIColor.black
        mPreferences.positioning.maxWidth = 200
        mPreferences.animating.dismissTransform = CGAffineTransform(translationX: 0, y: -15)
        mPreferences.animating.showInitialTransform = CGAffineTransform(translationX: 0, y: -15)
        mPreferences.animating.showInitialAlpha = 0
        mPreferences.animating.showDuration = 1
        mPreferences.animating.dismissDuration = 1
        
        mSlider.minimumValue = 500.0
        mSlider.maximumValue = 1500.0
        mSlider.tintColor = UIColor.black
        mSlider.addTarget(self, action: #selector(sliderDidChange(_:)), for: .valueChanged)
        self.view.addSubview(mSlider)
        mSlider.snp.makeConstraints { (make) in
            make.bottom.equalTo(-80)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        mSlider.isHidden = true
        
        curLocation.backgroundColor = UIColor.clear
        curLocation.font = UIFont.systemFont(ofSize: 12)
        curLocation.textColor = UIColor.black
        self.view.addSubview(curLocation)
        curLocation.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.top.equalTo(150)
        }
        
        distanceLbl.backgroundColor = UIColor.clear
        distanceLbl.font = UIFont.systemFont(ofSize: 12)
        distanceLbl.textColor = UIColor.black
        self.view.addSubview(distanceLbl)
        distanceLbl.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.top.equalTo(curLocation.snp.bottom).offset(10)
        }
        
        // 1.1
        mResultsViewController = GMSAutocompleteResultsViewController()
        mResultsViewController?.delegate = self
        
        mSearchController = UISearchController(searchResultsController: mResultsViewController)
        mSearchController?.searchResultsUpdater = mResultsViewController
        
        // Put the search bar in the navigation bar.
        mSearchController?.searchBar.sizeToFit()
        mSearchController?.searchBar.delegate = self
        navigationItem.titleView = mSearchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        mSearchController?.hidesNavigationBarDuringPresentation = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func sliderDidChange(_ slider: UISlider) {
        let value = slider.value
        mCircle.radius = CLLocationDistance(value)
    }
    
    // MARK: - notification
    func getAuthorizaion(_ notice: Notification)  {
        mGmaps.isMyLocationEnabled = true
    }
    
    func updateLocation(_ notice: Notification) {
        let userInfo = notice.userInfo
        let location = userInfo!["newLocation"] as! CLLocation
        let eventDate = location.timestamp
        let time = eventDate.timeIntervalSinceNow
        curLocation.text = "\(time)"
        
        // calculate the location
        var distance: CLLocationDistance?
        if mSelectedLocation != nil {
            distance = YjiComFuncs.getMeterFrom(location, newLocation: mSelectedLocation!)
            if let distanceValue = distance {
                distanceLbl.text = "\(String(describing: distanceValue))"
                if  distanceValue < mCircle.radius {
                    if mYjiLocationManager?.mIsBackgroundState == true {
                        // background handle
                        YjiComFuncs.sendNativeNotification()
                    } else {
                        self.showAlertWith("通知", msg: "設定した範囲に入りました！！")
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mYjiLocationManager?.stopUpdateLocation()
        mGmaps.removeObserver(self, forKeyPath: "myLocation", context: nil)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !mDidFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
            mGmaps.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 5.0)
            mGmaps.settings.myLocationButton = true
            mDidFindMyLocation = true
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if (mSearchController?.searchBar.isFirstResponder)! {
            mSearchController?.searchBar.resignFirstResponder()
        } else {
            self.updateMap(coordinate)
        }
    }
    
    func updateMap(_ coordinate: CLLocationCoordinate2D) {
        
        
        // to get location Info
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (placemarks, error) -> Void in
            guard error == nil else {return}
            //            print(placemarks)
            let placemark = placemarks![0]
            
            var title = ""
            if let countryCode = placemark.isoCountryCode {
                title = title + countryCode
            }
            if let country = placemark.country {
                title = title + country
            }
            
            var snippet = ""
            if let postalCode = placemark.postalCode {
                snippet = snippet + postalCode
            }
            if let administrativeArea = placemark.administrativeArea {
                snippet = snippet + administrativeArea
            }
            if let locality = placemark.locality {
                snippet = snippet + locality
            }
            if let subLocality = placemark.subLocality {
                snippet = snippet + subLocality
            }
            if let subThoroughfare = placemark.subThoroughfare {
                snippet = snippet + subThoroughfare
            }
            
            self.mLocationMarker.position = coordinate
            self.mLocationMarker.title = title
            self.mLocationMarker.snippet = snippet
            self.mLocationMarker.icon = UIImage(named: "mappin")
            self.mLocationMarker.appearAnimation = GMSMarkerAnimation.pop
            self.mLocationMarker.map = self.mGmaps
            
            self.reloadViewWithPosition(coordinate)
        }
    }
    
    func reloadViewWithPosition(_ position: CLLocationCoordinate2D) {
        mGmaps.camera = GMSCameraPosition.camera(withTarget: position, zoom: 15)
        mSelectedLocation = CLLocation(latitude: position.latitude, longitude: position.longitude)
        
        mCircle.position = position
        mCircle.radius = 500 // default
        mCircle.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05)
        mCircle.strokeColor = UIColor.red
        mCircle.strokeWidth = 2
        mCircle.map = self.mGmaps
        
        mSlider.value = 500.0
        mSlider.isHidden = false
        self.stopProgressView()
    }
    
    func startMonitor() {
        if mCircle.map == nil || mLocationMarker.map == nil {
            return
        }
        curLocation.isHidden = false
        distanceLbl.isHidden = false
        mYjiLocationManager?.startUpdateLocation()
    }
    
    func cancelMonitor() {
        curLocation.isHidden = true
        distanceLbl.isHidden = true
        mYjiLocationManager?.stopUpdateLocation()
        mCircle.map = nil
        mLocationMarker.map = nil
        mSlider.isHidden = true
    }
    
    // MARK:- search delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
        self.showProgressView()
        searchBar.resignFirstResponder()
        let mapTask = YjiMapTask()
        mapTask.geocodeAddress(searchBar.text) { (status, success) in
            if status == "OK" && success == true {
                let locationInfo = CLLocationCoordinate2DMake(mapTask.mFetchedAddressLatitude, mapTask.mFetchedAddressLongitude)
                self.updateMap(locationInfo)
            } else {
                self.stopProgressView()
                let av = UIAlertController(title: "Failure", message: "Sorry,I can't find the way!", preferredStyle: .alert)
                av.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.mYjiLocationManager?.stopUpdateLocation()
                }))
                self.present(av, animated: true, completion: nil)
            }
        }
    }
    
    // 1.1
    func searchWith(name: String) {
        self.showProgressView()
        let mapTask = YjiMapTask()
        mapTask.geocodeAddress(name) { (status, success) in
            if status == "OK" && success == true {
                let locationInfo = CLLocationCoordinate2DMake(mapTask.mFetchedAddressLatitude, mapTask.mFetchedAddressLongitude)
                self.updateMap(locationInfo)
            } else {
                self.stopProgressView()
                let av = UIAlertController(title: "Failure", message: "Sorry,I can't find the way!", preferredStyle: .alert)
                av.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.mYjiLocationManager?.stopUpdateLocation()
                }))
                self.present(av, animated: true, completion: nil)
            }
        }
    }
    
    func launchHelpTip(btn: UIButton) {
        for tmpView in self.view.subviews {
            if tmpView is EasyTipView {
                (tmpView as! EasyTipView).dismiss(withCompletion: nil)
                return
            }
        }
        EasyTipView.show(forView: btn,
                         withinSuperview: self.view,
                         text: "地図をタップして範囲を設定した後に監視できます。\n右下のボタンで自分の位置に戻ります。",
                         preferences: mPreferences)
    }
}

// 1.1
extension YjiGMapSearchVc: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        mSearchController?.isActive = false
        // Do something with the selected place.
//        print(mSearchController?.searchBar.text!)
//        print("Place name: \(place.name)")
//        print("Place address: \(place.formattedAddress)")
//        print("Place attributions: \(place.attributions)")
        self.searchWith(name: place.name)
        dismiss(animated: true, completion: nil)

    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
