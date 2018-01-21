//
//  Block.swift
//  BlockchainSwift
//
//  Created by Shuichi Tsutsumi on 2018/01/08.
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//
//  Thanks to:
//      https://qiita.com/hidehiro98/items/841ece65d896aeaa8a2a
//      https://hackernoon.com/learn-blockchains-by-building-one-117428612f46

import Foundation

struct Block: Codable {
    let index: Int
    let timestamp: Double
    let transactions: [Transaction]
    let proof: Int
    let previousHash: Data

    // Hashes a Block
    // ブロックの SHA-256 ハッシュを作る
    func hash() -> Data {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        return data.sha256()
    }
    
    func description() -> String {
        let json = try! JSONEncoder().encode(self)
        return String(data: json, encoding: .utf8)!
    }
}

extension Data {
    // https://stackoverflow.com/questions/25388747/sha256-in-swift
    func sha256() -> Data {
        guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { fatalError() }
        CC_SHA256((self as NSData).bytes, CC_LONG(self.count), res.mutableBytes.assumingMemoryBound(to: UInt8.self))
        return res as Data
    }
    
    func hexDigest() -> String {
        return self.map({ String(format: "%02x", $0) }).joined()
    }
}

extension Encodable {
    var jsonObject: AnyObject? {
        let encoder = JSONEncoder()
        guard let data:Data = try? encoder.encode(self) else {
            return nil
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return nil
        }
        return json as AnyObject
    }
}
