//
//  SearchFilter.swift
//  owadra
//
//  Created by 生田達也 on 2016/12/28.
//  Copyright © 2016年 Tatsuya IKUTA. All rights reserved.
//

import Foundation
import UIKit
import Ji

protocol SearchFilterDelegate {
    func filterDidChanged(newUrl: URL, newDefaultDungeonName: String)
}

class SearchFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var tableView: UITableView!
    
    var dungeonList: DungeonList = [:]
    var delegate: SearchFilterDelegate?
    
    static func viewController() -> SearchFilterViewController {
        let sb = UIStoryboard.init(name: "SearchFilter", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! SearchFilterViewController
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PazdraMultiComModel.manager.dungeonList { (list) in
            self.dungeonList = list
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dungeonList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = dungeonList[indexPath.row]?.keys.first!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            delegate?.filterDidChanged(newUrl: ((dungeonList[indexPath.row])?.values.first)!, newDefaultDungeonName: "")
        } else {
            delegate?.filterDidChanged(newUrl: (dungeonList[indexPath.row]?.values.first)!,
                                       newDefaultDungeonName: (dungeonList[indexPath.row]?.keys.first)!)
        }
        _ = navigationController?.popViewController(animated: true)
    }
}
