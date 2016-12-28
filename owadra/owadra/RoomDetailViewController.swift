//
//  RoomDetailViewController.swift
//  owadra
//
//  Created by 生田達也 on 2016/12/26.
//  Copyright © 2016年 Tatsuya IKUTA. All rights reserved.
//

import Foundation
import UIKit

class RoomDetailViewController: UIViewController {
    @IBOutlet weak var dungeonLabel: UILabel!
    @IBOutlet weak var leaderLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var roomIdTextField: UITextField!
    
    var model: PazdraMultiComRoom? = nil
    
    static func viewController(model: PazdraMultiComRoom) -> RoomDetailViewController {
        let sb = UIStoryboard.init(name: "RoomDetail", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! RoomDetailViewController
        vc.model = model
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dungeonLabel.text = model!.dungeon
        leaderLabel.text = model!.leader
        commentLabel.text = model!.comment
        roomIdTextField.text = ""
        
        model!.roomId { (roomId) in
            DispatchQueue.main.async {
                self.roomIdTextField.text = roomId
            }
        }
    }
    
    @IBAction func launch(sender: AnyObject) {
        guard let roomId = roomIdTextField.text else {
            return
        }
        UIPasteboard.general.setValue(roomId, forPasteboardType: "public.text")
        
        let pazdra = URL.init(string: "puzzleanddragons:")
        UIApplication.shared.open(pazdra!, options: [String: Any](), completionHandler: nil)
    }
}
