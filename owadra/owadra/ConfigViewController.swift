//
//  ConfigViewController.swift
//  owadra
//
//  Created by 生田達也 on 2016/12/28.
//  Copyright © 2016年 Tatsuya IKUTA. All rights reserved.
//

import Foundation
import UIKit

class ConfigViewController: UIViewController {
    static func viewController() -> ConfigViewController {
        let sb = UIStoryboard.init(name: "Config", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! ConfigViewController
        
        return vc
    }
}
