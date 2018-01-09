//
//  Blockchain.swift
//  BlockchainSwift
//
//  Created by Shuichi Tsutsumi on 2018/01/08.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//
//  Thanks to:
//      https://qiita.com/hidehiro98/items/841ece65d896aeaa8a2a
//      https://hackernoon.com/learn-blockchains-by-building-one-117428612f46

import Foundation

class Blockchain {

    // an initial empty list to store transactions
    // トランザクションを納めるための空のリスト
    private var currentTransactions: [Transaction] = []

    // an initial empty list to store our blockchain
    // ブロックチェーンを納めるための最初の空のリスト
    var chain: [Block] = []

    init() {
        // Create the genesis block
        // ジェネシスブロックを作る
        createBlock(proof: 100, previousHash: "1".data(using: .utf8))
    }
    
    // Creates a new Block and adds it to the chain
    // 新しいブロックを作り、チェーンに加える
    @discardableResult
    func createBlock(proof: Int, previousHash: Data? = nil) -> Block {
        let prevHash: Data
        if let previousHash = previousHash {
            prevHash = previousHash
        } else {
            // Hash of previous Block
            // 前のブロックのハッシュ
            prevHash = lastBlock().hash()
        }
        let block = Block(index: chain.count+1,
                          timestamp: Date().timeIntervalSince1970,
                          transactions: currentTransactions,
                          proof: proof,
                          previousHash: prevHash)
        
        // Reset the current list of transactions
        // 現在のトランザクションリストをリセット
        currentTransactions = []
        
        chain.append(block)
        
        return block
    }

    // Adds a new transaction to the list of transactions
    // 新しいトランザクションをリストに加える
    @discardableResult
    func createTransaction(sender: String, recipient: String, amount: Int) -> Int {
        // Creates a new transaction to go into the next mined Block
        // 次に採掘されるブロックに加える新しいトランザクションを作る
        let transaction = Transaction(sender: sender, recipient: recipient, amount: amount)
        currentTransactions.append(transaction)
        
        // Returns the index of the Block that will hold this transaction
        // このトランザクションを含むブロックのアドレスを返す
        return lastBlock().index + 1
    }
    
    // Returns the last Block in the chain
    // チェーンの最後のブロックを返す
    func lastBlock() -> Block {
        guard let last = chain.last else {
            fatalError("The chain should have at least one block as a genesis.")
        }
        return last
    }
    
    // Simple Proof of Work Algorithm:
    //   - Find a number p' such that hash(pp') contains leading 4 zeroes, where p is the previous p'
    //   - p is the previous proof, and p' is the new proof
    // シンプルなプルーフ・オブ・ワークのアルゴリズム:
    //   - hash(pp') の最初の4つが0となるような p' を探す
    //   - p は前のプルーフ、 p' は新しいプルーフ
    class func proofOfWork(lastProof: Int) -> Int {
        // TODO: Shold be implemented!!!!
        return 0
    }    
}

