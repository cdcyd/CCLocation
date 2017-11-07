//
//  LocationManager.swift
//  CCLocation
//
//  Created by 佰道聚合 on 2017/11/7.
//  Copyright © 2017年 cyd. All rights reserved.
//

import UIKit
import CoreLocation

typealias LocationBlock  = (_ error: Error?, _ location:Location?) -> Swift.Void
typealias PlacemarkBlock = (_ error: Error?, _ placemark:Placemark?) -> Swift.Void

class LocationManager: NSObject, CLLocationManagerDelegate {
 
    /**
     * 定位管理:
     * 1.持续定位和单次定位同时只能使用其中一个
     * 2.全局最多只有一个block回掉
     * 3.所以如果已经开启了持续定位，则在其它地方可以直接通过下面两个属性取到地址信息
     */
    var currentLocation:Location?
    var currentPlacemark:Placemark?
    
    private var locationBlock:LocationBlock?
    private var placemarkBlock:PlacemarkBlock?
    private var isOnce = true
    
    private let locationManager:CLLocationManager = CLLocationManager()
    
    private static let instance = LocationManager()
    static func shared() -> LocationManager {
        return instance
    }
    
    private override init() {
        super.init()
        self.setupManager()
    }
    
    private func setupManager() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 10
        self.locationManager.requestAlwaysAuthorization()
    }
    
    /// 开始定位 once 是否是单次定位
    func startUpdatingLocation(once:Bool = true, location:LocationBlock?, placemark:PlacemarkBlock?) {
        self.isOnce = once
        self.locationBlock  = location
        self.placemarkBlock = placemark
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.perform(#selector(LocationManager.locationTimeout), with: nil, afterDelay: 30)
    }
    
    /// 结束定位
    @objc func stopUpdatingLocation(){
        self.locationManager.delegate = nil
        self.locationManager.stopUpdatingLocation()
    }
    
    /// 定位超时
    @objc private func locationTimeout() {
        self.stopUpdatingLocation()
        self.locationBlock?(NSError(domain: "定位超时", code: 408, userInfo: nil), nil)
        self.placemarkBlock?(NSError(domain: "定位超时", code: 408, userInfo: nil), nil)
    }
    
    // delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: print("CoreLocation：用户还未决定授权"); break
        case .restricted: print("CoreLocation：访问受限"); break
        case .denied: print("CoreLocation：用户已授权"); break
        case .authorizedAlways: print("CoreLocation：获得前后台授权"); break
        case .authorizedWhenInUse: print("CoreLocation：获得前台授权"); break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // 获取最新的坐标
        guard let last = locations.last else {
            return
        }
        print("当前坐标:" + "\(last)")
        
        // 经纬度
        let location = Location(location: last)
        self.currentLocation = location
        self.locationBlock?(nil, location)
        
        // 逆地址解析
        if self.placemarkBlock != nil {
            self.reverseGeocodeLocation(location: last)
        }
        
        // 如果是单次定位，则停止
        if self.isOnce {
            self.stopUpdatingLocation()
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(LocationManager.locationTimeout), object: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("CoreLocation：定位失败" + error.localizedDescription)
        self.stopUpdatingLocation()
        self.locationBlock?(error, nil)
        self.placemarkBlock?(error, nil)
    }
    
    private func reverseGeocodeLocation(location:CLLocation){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (marks, error) in
            let mark:Placemark? = marks != nil ? Placemark(place: marks!.first!) : nil
            self.currentPlacemark = mark
            self.placemarkBlock?(error, mark)
            
            if marks?.first != nil {
                print("当前位置:" + "\(marks!.first!)")
            }
        }
    }
}
