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
import Swifter
import Alamofire
import BrightFutures

class Blockchain {
    
    struct ChainResponse: Codable {
        let chain: [Block]
        let length: Int
    }

    // an initial empty list to store transactions
    // トランザクションを納めるための空のリスト
    private var currentTransactions: [Transaction] = []

    // an initial empty list to store our blockchain
    // ブロックチェーンを納めるための最初の空のリスト
    var chain: [Block] = []
    
    // ノード
    private(set) var nodes = Set<String>()
    
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
        var proof: Int = 0
        while !validProof(lastProof: lastProof, proof: proof) {
            proof += 1
        }
        return proof
    }
    
    // Validates the Proof:
    //   - Does hash(last_proof, proof) contain 4 leading zeroes?
    class func validProof(lastProof: Int, proof: Int) -> Bool {
        guard let guess = String("\(lastProof)\(proof)").data(using: .utf8) else {
            fatalError()
        }
        let guess_hash = guess.sha256().hexDigest()
        return guess_hash.prefix(4) == "0000"
    }
    
    // ノードリストに新しいノードを加える
    //   - ノードのアドレス 例: '192.168.0.5'
    public func registerNode(address: String) {
        nodes.insert("http://\(address):5000")
    }
    
    // ブロックチェーンが正しいかを確認する
    class func validChain(chain: [Block]) -> Bool {
        guard chain.count > 0 else {
            // genesis block exist
            fatalError()
        }
        var lastBlock: Block = chain[0]
        var currentIndex: Int = 1
        while currentIndex < chain.count {
            let block = chain[currentIndex]
            print("\(lastBlock)")
            print("\(block)")
            print("\n--------------\n")
            // ブロックのハッシュが正しいかを確認
            if block.previousHash != lastBlock.hash() {
                return false
            }
            
            // プルーフ・オブ・ワークが正しいかを確認
            if !validProof(lastProof: lastBlock.proof, proof: block.proof) {
                return false
            }
            
            lastBlock = block
            currentIndex += 1
        }
        return true
    }
    
    // これがコンセンサスアルゴリズムだ。ネットワーク上の最も長いチェーンで自らのチェーンを
    // 置き換えることでコンフリクトを解消する。
    // - return:  自らのチェーンが置き換えられると true 、そうでなれけば false
    func resolveConflict(_ completion: @escaping (_ result: Bool) -> Void) {
        var maxLength = self.chain.count
        // 他のすべてのノードのチェーンを確認
        self.nodes
        .map({ Blockchain.getChain(node: $0)})
        .sequence()
        .onSuccess { (responses:[ChainResponse]) -> Void in
            var newChain: [Block]? = nil
            for res in responses {
                // そのチェーンがより長いか、有効かを確認
                if maxLength < res.length {
                    if Blockchain.validChain(chain: res.chain) {
                        maxLength = res.length
                        newChain = res.chain
                    } else {
                        print("Invalid chain!")
                    }
                }
            }
            // もし自らのチェーンより長く、かつ有効なチェーンを見つけた場合それで置き換える
            if let newChain = newChain {
                self.chain = newChain
                print("Long length chain found")
                completion(true)
            } else {
                completion(false)
            }
        }
        .onFailure { (error: NSError) in
            completion(false)
            print("Failed to get neighbor node!")
        }
    }
    
    enum BlockChainError: Error {
        case general
    }

    private static func getChain(node: String) -> Future<ChainResponse, NSError> {
        let promise = Promise<ChainResponse, NSError>()
        let queue = DispatchQueue(label: "request", attributes: .concurrent)
        Alamofire.request("\(node)/chain").responseData(queue: queue, completionHandler: { response in
            switch response.result {
            case .success(let data):
                if let res = try? JSONDecoder().decode(ChainResponse.self, from: data) {
                    promise.success(res)
                } else {
                    promise.failure(BlockChainError.general as NSError)
                }
            case .failure(let error):
                promise.failure(error as NSError)
            }
        })
        return promise.future
    }
    
}

