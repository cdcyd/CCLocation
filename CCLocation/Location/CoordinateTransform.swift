//
//  CoordinateTransform.swift
//  CCLocation
//
//  Created by 佰道聚合 on 2017/11/7.
//  Copyright © 2017年 cyd. All rights reserved.
//
import CoreLocation

private let a = 6378245.0
private let ee = 0.00669342162296594323
private let x_M_PI = Double.pi * 3000.0 / 180.0

private func outOfChina(_ coordinate:CLLocationCoordinate2D) -> Bool{
    if (coordinate.longitude < 72.004 || coordinate.longitude > 137.8347){
        return true
    }
    if (coordinate.latitude < 0.8293 || coordinate.latitude > 55.8271){
        return true
    }
    return false
}

private func transformLat(_ x: Double, _ y: Double) -> Double{
    var ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x))
    ret += (20.0 * sin(6.0 * x * Double.pi) + 20.0 * sin(2.0 * x * Double.pi)) * 2.0 / 3.0
    ret += (20.0 * sin(y * Double.pi) + 40.0 * sin(y / 3.0 * Double.pi)) * 2.0 / 3.0
    ret += (160.0 * sin(y / 12.0 * Double.pi) + 320 * sin(y * Double.pi / 30.0)) * 2.0 / 3.0
    return ret
}

private func transformLon(_ x: Double, _ y: Double) -> Double{
    var ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x))
    ret += (20.0 * sin(6.0 * x * Double.pi) + 20.0 * sin(2.0 * x * Double.pi)) * 2.0 / 3.0
    ret += (20.0 * sin(x * Double.pi) + 40.0 * sin(x / 3.0 * Double.pi)) * 2.0 / 3.0
    ret += (150.0 * sin(x / 12.0 * Double.pi) + 300.0 * sin(x / 30.0 * Double.pi)) * 2.0 / 3.0
    return ret
}

// 地球坐标系 (WGS-84) -> 火星坐标系 (GCJ-02)
func wgs2gcj(_ coordinate:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    if (outOfChina(coordinate)) {
        return coordinate;
    }
    let wgLat = coordinate.latitude
    let wgLon = coordinate.longitude
    var dLat = transformLat(wgLon - 105.0, wgLat - 35.0)
    var dLon = transformLon(wgLon - 105.0, wgLat - 35.0)
    let radLat = wgLat / 180.0 * Double.pi
    var magic = sin(radLat)
    magic = 1 - ee * magic * magic
    let sqrtMagic = sqrt(magic)
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * Double.pi)
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * Double.pi)
    return CLLocationCoordinate2DMake(wgLat + dLat, wgLon + dLon)
}

// 火星坐标系 (GCJ-02) -> 地球坐标系 (WGS-84)
func gcj2wgs(_ coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    if (outOfChina(coordinate)) {
        return coordinate
    }
    let c2 = wgs2gcj(coordinate)
    return CLLocationCoordinate2DMake(2 * coordinate.latitude - c2.latitude, 2 * coordinate.longitude - c2.longitude)
}

// 火星坐标系 (GCJ-02) -> 百度坐标系 (BD-09)
func bd_encrypt(_ coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    let x = coordinate.longitude, y = coordinate.latitude
    let z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_M_PI)
    let theta = atan2(y, x) + 0.000003 * cos(x * x_M_PI)
    return CLLocationCoordinate2DMake(z * sin(theta) + 0.006, z * cos(theta) + 0.0065)
}

// 百度坐标系 (BD-09) -> 火星坐标系 (GCJ-02)
func bd_decrypt(_ coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    let x = coordinate.latitude - 0.0065, y = coordinate.longitude - 0.006
    let z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_M_PI)
    let theta = atan2(y, x) - 0.000003 * cos(x * x_M_PI)
    return CLLocationCoordinate2DMake(z * sin(theta), z * cos(theta))
}
