//
//  PazdraMultiModel.swift
//  owadra
//
//  Created by 生田達也 on 2016/12/26.
//  Copyright © 2016年 Tatsuya IKUTA. All rights reserved.
//

import Ji
import Foundation
import UIKit

let IOS10_SAFARI_USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_0_1 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Version/10.0 Mobile/14A403 Safari/602.1"

struct PazdraMultiComRoom {
    var detail: URL
    
    var date: String?
    var dungeon: String?
    var leader: String?
    var comment: String?
    
    var icon: URL
    
    func roomId(_ completion: ((String?) -> Void)?) {
        let conf = URLSessionConfiguration.default
        conf.httpAdditionalHeaders = ["User-Agent": IOS10_SAFARI_USER_AGENT]
        
        let session = URLSession.init(configuration: conf)
        session.dataTask(with: self.detail) { (data, response, error) in
            guard let theData = data else {
                return
            }
            guard let doc = Ji(htmlData: theData) else {
                return
            }
            
            let id = doc.xPath("//input[@type=\"text\"]/@value")?.first?.content
            
            completion?(id)
        }.resume()
    }
}

typealias DungeonList = [Int: [String: URL]]
typealias RoomList = [PazdraMultiComRoom]

class PazdraMultiComModel {
    // シングルトン
    static let manager = PazdraMultiComModel()
    private init() {
    }
    
    let baseUrl = URL.init(string: "https://xn--0ckox4a8d3cp.com")!
    private var _currentUrl: URL?
    
    private var _roomList: [PazdraMultiComRoom] = []
    private var _dungeonList: [Int: [String: URL]] = [:]
    private var _page = 0
    
    func dungeonList(completion: ((DungeonList) -> Void)?) {
        if _dungeonList.count > 0 {
            completion?(_dungeonList)
        } else {
            // 初回通信
            let conf = URLSessionConfiguration.default
            conf.httpAdditionalHeaders = ["User-Agent": IOS10_SAFARI_USER_AGENT]
            
            let session = URLSession.init(configuration: conf)
            session.dataTask(with: baseUrl) { (data, response, error) in
                guard let theData = data else {
                    return
                }
                guard let doc = Ji(htmlData: theData) else {
                    return
                }
                
                var result: DungeonList = [0: ["検索条件解除": self.baseUrl]]
                for (i, node) in doc.xPath("//div[@id=\"box_search\"]/*/li/*")!.enumerated() {
                    let dungeonName = node.xPath("./text()").first!.content!
                    let href = node.xPath("./@href").first!.content
                    let url = URL.init(string: href!, relativeTo: self.baseUrl)!
                    
                    result[i + 1] = [dungeonName: url]
                }
                
                self._dungeonList = result
                completion?(self._dungeonList)
            }.resume()
        }
    }
    
    func reloadRoomList(url: URL, completion: ((RoomList) -> Void)?) {
        _currentUrl = url
        _page = 0
        _roomList = []
        
        let conf = URLSessionConfiguration.default
        conf.httpAdditionalHeaders = ["User-Agent": IOS10_SAFARI_USER_AGENT]
        
        let session = URLSession.init(configuration: conf)
        session.dataTask(with: url) { (data, response, error) in
            guard let theData = data else {
                return
            }
            guard let doc = Ji(htmlData: theData) else {
                return
            }
            
            var result: [PazdraMultiComRoom] = []
            doc.xPath("//ul[@id=\"mlt_list\"]/li/*")?.forEach{
                let detail = URL.init(string: ($0.xPath("./@href").first?.content)!, relativeTo: self.baseUrl)!
                
                let date = $0.xPath(".//span[@class=\"day\"]/text()").first?.content
                
                let lv = $0.xPath(".//span[@class=\"lv\"]").first?.content
                let dungeon = $0.xPath(".//p[@class=\"danjon\"]/text()").first?.content
                
                let fullDungeon = dungeon != nil && lv != nil && lv != "─" ? dungeon! + lv! : dungeon
                
                let leader = $0.xPath(".//p[@class=\"my_leader\"]/text()").first?.content
                let comment = $0.xPath(".//p[not(@class)]/text()").reduce("", { (str1, ji) -> String in
                    str1 + "\n" + (ji.content != nil ? ji.content! : "")
                }).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                let icon = URL.init(string: ($0.xPath(".//img/@src").first?.content)!)
                
                let model = PazdraMultiComRoom(detail: detail, date: date, dungeon: fullDungeon, leader: leader, comment: comment, icon: icon!)
                result.append(model)
            }
            
            self._roomList = result
            completion?(self._roomList)
        }.resume()
    }
    
    func appendRoomList(completion: ((RoomList) -> Void)?) {
        _page += 1
        
        var components = URLComponents.init(string: _currentUrl!.absoluteString)
        
        var param: [String: String] = ["page": String(_page)]
        _currentUrl?.query?.components(separatedBy: "&").forEach{
            let kv = $0.components(separatedBy: "=")
            param[kv[0]] = kv[1]
        }
        components?.queryItems = param.map{
            URLQueryItem.init(name: $0, value: $1)
        }
        
        let conf = URLSessionConfiguration.default
        conf.httpAdditionalHeaders = ["User-Agent": IOS10_SAFARI_USER_AGENT]
        
        let session = URLSession.init(configuration: conf)
        session.dataTask(with: (components?.url)!) { (data, response, error) in
            guard let theData = data else {
                return
            }
            guard let doc = Ji(htmlData: theData) else {
                return
            }
            
            var result: [PazdraMultiComRoom] = []
            doc.xPath("//ul[@id=\"mlt_list\"]/li/*")?.forEach{
                let detail = URL.init(string: ($0.xPath("./@href").first?.content)!, relativeTo: self.baseUrl)!
                
                let date = $0.xPath(".//span[@class=\"day\"]/text()").first?.content
                
                let lv = $0.xPath(".//span[@class=\"lv\"]").first?.content
                let dungeon = $0.xPath(".//p[@class=\"danjon\"]/text()").first?.content
                
                let fullDungeon = dungeon != nil && lv != nil && lv != "─" ? dungeon! + lv! : dungeon
                
                let leader = $0.xPath(".//p[@class=\"my_leader\"]/text()").first?.content
                let comment = $0.xPath(".//p[not(@class)]/text()").reduce("", { (str1, ji) -> String in
                    str1 + "\n" + (ji.content != nil ? ji.content! : "")
                }).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                let icon = URL.init(string: ($0.xPath(".//img/@src").first?.content)!)
                
                let model = PazdraMultiComRoom(detail: detail, date: date, dungeon: fullDungeon, leader: leader, comment: comment, icon: icon!)
                result.append(model)
            }
            
            self._roomList.append(contentsOf: result)
            completion?(self._roomList)
            }.resume()
    }
}
