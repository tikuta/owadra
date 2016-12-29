//
//  UIImageView+async.swift
//  owadra
//
//  Created by 生田達也 on 2016/12/30.
//  Copyright © 2016年 Tatsuya IKUTA. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func asyncLoad(url: URL, cache: URLCache) {
        guard let response = cache.cachedResponse(for: URLRequest.init(url: url)) else {
            let conf = URLSessionConfiguration.default
            conf.httpAdditionalHeaders = ["User-Agent": IOS10_SAFARI_USER_AGENT]
            
            let session = URLSession.init(configuration: conf)
            session.dataTask(with: url) { (data, response, error) in
                guard let theData = data else {
                    return
                }
                cache.storeCachedResponse(CachedURLResponse.init(response: response!, data: theData), for: URLRequest.init(url: url))
                
                DispatchQueue.main.async {
                    self.image = UIImage.init(data: theData)
                }
            }.resume()
            return
        }

        self.image = UIImage.init(data: response.data)
    }
}
