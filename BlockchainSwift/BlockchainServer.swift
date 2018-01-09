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
    func mine(recipient: String) -> Block {
        // We run the proof of work algorithm to get the next proof...
        // 次のプルーフを見つけるためプルーフ・オブ・ワークアルゴリズムを使用する
        let lastBlock = blockchain.lastBlock()
        let lastProof = lastBlock.proof
        let proof = Blockchain.proofOfWork(lastProof: lastProof)
        
        // We must receive a reward for finding the proof.
        // The sender is "0" to signify that this node has mined a new coin.
        // プルーフを見つけたことに対する報酬を得る
        // 送信者は、採掘者が新しいコインを採掘したことを表すために"0"とする
        blockchain.createTransaction(sender: "0", recipient: recipient, amount: 1)
        
        // Forge the new Block by adding it to the chain
        // チェーンに新しいブロックを加えることで、新しいブロックを採掘する
        let block = blockchain.createBlock(proof: proof)
        
        return block
    }
    
    // '/chain' endpoint
    func chain() -> [Block] {
        return blockchain.chain
    }
}
