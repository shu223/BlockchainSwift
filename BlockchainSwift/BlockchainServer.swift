//
//  BlockchainServer.swift
//  BlockchainSwift
//
//  Created by Shuichi Tsutsumi on 2018/01/09.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//
//  Blockchain as an API (This should be implemented as an API on a server.)
//  Thanks to:
//      https://qiita.com/hidehiro98/items/841ece65d896aeaa8a2a
//      https://hackernoon.com/learn-blockchains-by-building-one-117428612f46

import Foundation

class BlockchainServer {
    
    let blockchain = Blockchain()

    // '/transactions/new' endpoint
    func send(sender: String, recipient: String, amount: Int) -> Int {
        return blockchain.createTransaction(sender:sender, recipient:recipient, amount:amount)
    }
    
    // '/mine' endpoint
    func mine(recipient: String, completion: ((Block) -> Void)?) {
        // mine in the background
        DispatchQueue.global(qos: .default).async {
            let block = self.blockchain.mine(recipient: recipient)
            DispatchQueue.main.async(execute: {
                completion?(block)
            })
        }
    }
    
    // '/chain' endpoint
    func chain() -> [Block] {
        return blockchain.chain
    }
}
