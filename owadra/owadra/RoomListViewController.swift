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
    
    func filterDidChanged(newUrl: URL) {
        url = newUrl
        
        PazdraMultiComModel.manager.reloadRoomList(url: url) { (newList) in
            self.roomList = newList
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func reload(_ sender: UIRefreshControl) {
        PazdraMultiComModel.manager.reloadRoomList(url: url) { (newList) in
            self.roomList = newList
            DispatchQueue.main.async {
                self.tableView.reloadData()
                sender.endRefreshing()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = RoomDetailViewController.viewController(model: roomList[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        let model = roomList[indexPath.row]
        
        let dungeonLabel = cell.viewWithTag(10) as! UILabel
        dungeonLabel.text = model.dungeon ?? "(設定なし)"
        
        let leaderLabel = cell.viewWithTag(20) as! UILabel
        leaderLabel.text = model.leader
        
        let dateLabel = cell.viewWithTag(40) as! UILabel
        dateLabel.text = model.date
        
        let commentLabel = cell.viewWithTag(30) as! UILabel
        guard let theComment = model.comment else {
            commentLabel.text = ""
            return cell
        }
        
        commentLabel.text = (theComment as NSString).replacingOccurrences(of: "\n", with: " ")
        
        return cell
    }
}
