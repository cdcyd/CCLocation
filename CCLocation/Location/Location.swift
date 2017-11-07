//
//  Location.swift
//  CCLocation
//
//  Created by 佰道聚合 on 2017/11/7.
//  Copyright © 2017年 cyd. All rights reserved.
//

import UIKit
import CoreLocation

class Location: NSObject {
    
    /// location 必须是地球坐标系
    init(location:CLLocation) {
        super.init()
        self.coordinateWGS = location.coordinate
        self.coordinateGCJ = wgs2gcj(location.coordinate)
        self.coordinateBDU = bd_encrypt(self.coordinateGCJ)
        self.accuracy  = location.horizontalAccuracy
        self.timestamp = location.timestamp
    }
    
    /// 地球坐标 默认0.0
    var coordinateWGS: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    
    /// 火星坐标 默认0.0
    var coordinateGCJ: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    
    /// 百度坐标 默认0.0
    var coordinateBDU: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    
    /// 精度 默认0
    var accuracy: CLLocationAccuracy = 0
    
    /// 应用获取该坐标的时间 默认当前时间
    var timestamp: Date = Date()
    
}
