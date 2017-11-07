//
//  ViewController.swift
//  CCLocation
//
//  Created by 佰道聚合 on 2017/11/7.
//  Copyright © 2017年 cyd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.shared().startUpdatingLocation(once: true, location: { (error, location) in
//            print(location ?? "获取位置失败: " + error.debugDescription)
        }) { (error, placemark) in
//            print(placemark ?? "逆地址解析失败: " + error.debugDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

