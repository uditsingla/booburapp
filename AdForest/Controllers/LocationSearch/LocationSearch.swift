//
//  LocationSearch.swift
//  AdForest
//
//  Created by apple on 5/18/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import RangeSeekSlider
import NVActivityIndicatorView
import CoreLocation
import MapKit

protocol NearBySearchDelegate {
    func nearbySearchParams(lat: Double, long: Double, searchDistance: CGFloat)
}


class LocationSearch: UIViewController , RangeSeekSliderDelegate, NVActivityIndicatorViewable , CLLocationManagerDelegate {

    //MARK:- Outlets
    @IBOutlet weak var viewImage: UIView!{
        didSet{
            viewImage.circularView()
        }
    }
    @IBOutlet weak var imgRoute: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var oltCancel: UIButton!{
        didSet {
            if let bgColor = defaults.string(forKey: "mainColor") {
                oltCancel.backgroundColor = Constants.hexStringToUIColor(hex: bgColor)
            }
        }
    }
    @IBOutlet weak var oltSubmit: UIButton!{
        didSet {
            if let bgColor = defaults.string(forKey: "mainColor") {
                oltSubmit.backgroundColor = Constants.hexStringToUIColor(hex: bgColor)
            }
        }
    }
    @IBOutlet weak var seekBar: RangeSeekSlider!

    
    //MARK:- Properties
    var delegate: NearBySearchDelegate?
    
    var defaults = UserDefaults.standard
    var nearByDistance : CGFloat = 0
    var maximumValue: CGFloat = 0.0
    var sliderStep: CGFloat = 0
    let locationManager = CLLocationManager()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.adForest_populateData()
        self.hideBackButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Location Search")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
    }
   
    //MARK: - Custom
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func userLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        if locationManager.location != nil {
            if let lat = locationManager.location?.coordinate.latitude {
                self.latitude = lat
                print(latitude)
            }
            if let long = locationManager.location?.coordinate.longitude {
                self.longitude = long
                print(longitude)
            }
        }
    }

    
    func adForest_populateData() {
        if let settingsInfo = defaults.object(forKey: "settings") {
            let  settingObject = NSKeyedUnarchiver.unarchiveObject(with: settingsInfo as! Data) as! [String : Any]
            print(settingObject)
            
            let model = SettingsRoot(fromDictionary: settingObject)
            print(model)
            
            if let description = model.data.locationPopup.text {
                self.lblDescription.text = description
            }
            
            if let clearBtnText = model.data.locationPopup.btnClear {
                self.oltCancel.setTitle(clearBtnText, for: .normal)
            }
            if let submitBtnText = model.data.locationPopup.btnSubmit {
                self.oltSubmit.setTitle(submitBtnText, for: .normal)
            }
            
            if let sliderStepRange = model.data.locationPopup.sliderStep {
                self.sliderStep = CGFloat(sliderStepRange)
            }
        }
          self.userLocation()
          self.sliderSetting()
    }
    
    //MARK:- Range Slider Delegate
    func sliderSetting() {
        seekBar.delegate = self
        seekBar.disableRange = true
        seekBar.enableStep = true
        seekBar.step = sliderStep
        if let bgColor = UserDefaults.standard.string(forKey: "mainColor") {
            seekBar.tintColor = Constants.hexStringToUIColor(hex: bgColor)
            seekBar.minLabelColor = Constants.hexStringToUIColor(hex: bgColor)
            seekBar.maxLabelColor = Constants.hexStringToUIColor(hex: bgColor)
            seekBar.handleColor = Constants.hexStringToUIColor(hex: bgColor)
            seekBar.handleBorderColor = Constants.hexStringToUIColor(hex: bgColor)
            seekBar.colorBetweenHandles = Constants.hexStringToUIColor(hex: bgColor)
            seekBar.initialColor = Constants.hexStringToUIColor(hex: bgColor)
        }
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        if slider === seekBar {
            print("Standard slider updated. Min Value: \(minValue) Max Value: \(maxValue)")
            let mxValue = maxValue
            self.maximumValue = mxValue
            self.nearByDistance = mxValue
            
        }
    }
    
    func didStartTouches(in slider: RangeSeekSlider) {
        print("did start touches")
    }
    
    func didEndTouches(in slider: RangeSeekSlider) {
        print("did end touches")
    }
    
    
    //MARK:- IBActions
    @IBAction func actionSubmit(_ sender: Any) {
        self.dismissVC {
            print(self.latitude, self.longitude, self.nearByDistance)
            self.delegate?.nearbySearchParams(lat: self.latitude, long: self.longitude, searchDistance: self.nearByDistance)
        }
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        self.dismissVC(completion: nil)
    }
}
