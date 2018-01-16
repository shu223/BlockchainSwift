//
//  ViewController.swift
//  BlockchainSwift
//
//  Created by Shuichi Tsutsumi on 2018/01/08.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private let myId = "me"
    private let recipientId = "someone"
    private let server = BlockchainServer()
    
    @IBOutlet private weak var logView: UITextView!
    @IBOutlet private weak var chainView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        logView.text = ""
        
        updateChain()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func updateChain() {
        let chain = server.chain()
        var text = "chain:\n"
        for block in chain {
            text.append(block.description() + "\n")
        }
        chainView.text = text
        print(text)
    }
    
    @IBAction func sendBtnTapped(_ sender: UIButton) {
        let index = server.send(sender: myId, recipient: recipientId, amount: 5)
        let text = "Transaction will be added to Block \(index)"
        logView.text = text + "\n" + logView.text
        print(text)
        updateChain()
    }
    
    @IBAction func mineBtnTapped(_ sender: UIButton) {
        let startTime = CACurrentMediaTime()
        let text = "Mining..."
        self.logView.text = text + "\n" + self.logView.text

        server.mine(recipient: myId, completion: { (block) in
            let text = String(format: "New Block Forged (%.1f s)", CACurrentMediaTime() - startTime)
            self.logView.text = text + "\n" + self.logView.text
            print(text+block.description())
            self.updateChain()
        })
    }
}

