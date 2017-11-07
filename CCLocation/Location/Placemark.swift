//
//  Placemark.swift
//  CCLocation
//
//  Created by 佰道聚合 on 2017/11/7.
//  Copyright © 2017年 cyd. All rights reserved.
//

import UIKit
import CoreLocation

class Placemark: NSObject {
    
    init(place:CLPlacemark) {
        super.init()
        
        self.loction  = Location(location: place.location ?? CLLocation(latitude: 0, longitude: 0))
        self.country  = place.country
        self.prov     = place.administrativeArea
        self.city     = place.locality
        self.dist     = place.subLocality
        self.street   = place.thoroughfare
        self.number   = place.subThoroughfare
        self.name     = place.name
        self.zipcode  = place.postalCode
        self.timezone = place.timeZone?.identifier
        
    }
    
    /// 经纬度
    var loction:Location!
    
    /// 国
    var country:String?
    
    /// 省
    var prov:String?
    
    /// 市(如果是 直辖市 它总是为nil)
    var city:String?
    
    /// 区
    var dist:String?
    
    /// 街道+门牌号
    var street:String?
    
    /// 附门牌号
    var number:String?
    
    /// 名称
    var name:String?
    
    /// 邮编
    var zipcode:String?
    
    /// 时区
    var timezone:String?
    
    /// 详细地址(国+省+市+区+街道+门牌号+附门牌号)
    var formatAddress:String {
        get{
            return "\(country ?? "")\(prov ?? "")\(city ?? "")\(dist ?? "")\(street ?? "")\(number ?? "")"
        }
    }
    
    /// 市+区+名称
    var brefAddress:String {
        get{
            return "\(city ?? "")\(dist ?? "")\(name ?? "")"
        }
    }
}
