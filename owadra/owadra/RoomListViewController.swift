//
//  RoomListViewController.swift
//  owadra
//
//  Created by 生田達也 on 2016/12/26.
//  Copyright © 2016年 Tatsuya IKUTA. All rights reserved.
//

import Foundation
import UIKit

class RoomListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchFilterDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    private var roomList: [PazdraMultiComRoom] = []
    var url: URL = PazdraMultiComModel.manager.baseUrl
    var defaultDungeonName: String = ""
    private var _imageCache = URLCache.init(memoryCapacity: 1 * 1024 * 1024, diskCapacity: 0, diskPath: nil)
    
    static func viewController() -> RoomListViewController {
        let sb = UIStoryboard.init(name: "RoomList", bundle: nil)
        let vc = sb.instantiateInitialViewController()
        
        return vc as! RoomListViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(reload(_:)), for: .valueChanged)
        tableView.refreshControl = refresh
        
        let categoryButton = UIBarButtonItem.init(title: "ダンジョン", style: .plain, target: self, action: #selector(pushToSearchFilter(_:)))
        navigationItem.rightBarButtonItem = categoryButton
        
        let reloadButton = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(reload(_:)))
        navigationItem.leftBarButtonItem = reloadButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PazdraMultiComModel.manager.reloadRoomList(url: url) { (newList) in
            self.roomList = newList
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func pushToSearchFilter(_ sender: AnyObject) {
        let vc = SearchFilterViewController.viewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func filterDidChanged(newUrl: URL, newDefaultDungeonName: String) {
        url = newUrl
        defaultDungeonName = newDefaultDungeonName
        
        reload(self)
    }
    
    func reload(_ sender: AnyObject) {
        PazdraMultiComModel.manager.reloadRoomList(url: url) { (newList) in
            self.roomList = newList
            DispatchQueue.main.async {
                self.tableView.reloadData()
                (sender as? UIRefreshControl)?.endRefreshing()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < roomList.count {
            let vc = RoomDetailViewController.viewController(model: roomList[indexPath.row])
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let append = tableView.cellForRow(at: indexPath)
            append?.textLabel?.text = ""
            let indicator = append?.viewWithTag(10) as! UIActivityIndicatorView
            indicator.startAnimating()
            PazdraMultiComModel.manager.appendRoomList{ (newList) in
                DispatchQueue.main.async {
                    indicator.stopAnimating()
                    append?.textLabel?.text = "..."
                    
                    self.roomList = newList
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < roomList.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            
            let model = roomList[indexPath.row]
            
            let dungeonLabel = cell.viewWithTag(10) as! UILabel
            dungeonLabel.text = model.dungeon ?? defaultDungeonName
            
            let leaderLabel = cell.viewWithTag(20) as! UILabel
            leaderLabel.text = model.leader
            
            let dateLabel = cell.viewWithTag(40) as! UILabel
            dateLabel.text = model.date
            
            let commentLabel = cell.viewWithTag(30) as! UILabel
            commentLabel.text = model.comment?.replacingOccurrences(of: "\n", with: " ") ?? ""
            
            let iconView = cell.viewWithTag(50) as! UIImageView
            iconView.asyncLoad(url: model.icon, cache: _imageCache)
            
            return cell
        } else {
            let append = tableView.dequeueReusableCell(withIdentifier: "append")!
            
            append.textLabel?.textAlignment = .center
            append.textLabel?.text = "..."
            
            let indicator = append.viewWithTag(10) as! UIActivityIndicatorView
            indicator.stopAnimating()
            
            return append
        }
    }
}
