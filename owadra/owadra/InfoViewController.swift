//
//  InfoViewController.swift
//  owadra
//
//  Created by 生田達也 on 2016/12/28.
//  Copyright © 2016年 Tatsuya IKUTA. All rights reserved.
//

import Foundation
import UIKit

class InfoViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL.init(string: Bundle.main.path(forResource: "info", ofType: "html")!)!
        webView.loadRequest(URLRequest.init(url: url))
    }
}
