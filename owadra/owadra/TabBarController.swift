//
//  ViewController.swift
//  owadra
//
//  Created by 生田達也 on 2016/12/26.
//  Copyright © 2016年 Tatsuya IKUTA. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let pazdraMultiCom = UINavigationController.init(rootViewController: RoomListViewController.viewController())
        pazdraMultiCom.tabBarItem = UITabBarItem.init(title: "パズドラマルチ.com", image: nil, tag: 1)
        
        let config = UINavigationController.init(rootViewController: ConfigViewController.viewController())
        config.tabBarItem = UITabBarItem.init(tabBarSystemItem: .more, tag: 10)
        
        let viewControllers = [pazdraMultiCom, config]
        
        self.setViewControllers(viewControllers, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
}

