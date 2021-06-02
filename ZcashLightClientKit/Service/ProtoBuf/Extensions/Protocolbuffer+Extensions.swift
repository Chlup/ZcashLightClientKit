//
//  Protocolbuffer+Extensions.swift
//  ZcashLightClientKit
//
//  Created by Francisco Gindre on 12/09/2019.
//  Copyright © 2019 Electric Coin Company. All rights reserved.
//

import Foundation

extension CompactBlockRange {
    func blockRange() -> BlockRange {
        BlockRange(startHeight: lowerBound, endHeight: upperBound)
    }
}

extension BlockID {
    
    static let saplingActivationHeight: UInt64 = UInt64(ZcashSDK.SAPLING_ACTIVATION_HEIGHT)
    
    init(height: UInt64) {
        self = BlockID()
        self.height = height
    }
    
    static var saplingActivation: BlockID {
        BlockID(height: saplingActivationHeight)
    }
    
    init(height: BlockHeight) {
        self.init(height: UInt64(height))
    }
    
    func compactBlockHeight() -> BlockHeight? {
        BlockHeight(exactly: self.height)
    }
}

extension BlockRange {
    
    init(startHeight: Int, endHeight: Int? = nil) {
        self = BlockRange()
        self.start = BlockID(height: UInt64(startHeight))
        if let endHeight = endHeight {
            self.end = BlockID(height: UInt64(endHeight))
        }
    }
    
    static func sinceSaplingActivation(to height: UInt64? = nil) -> BlockRange {
       var blockRange = BlockRange()
        
        blockRange.start = BlockID.saplingActivation
        if let height = height {
            blockRange.end = BlockID.init(height: height)
        }
        return blockRange
    }
    
    var compactBlockRange: CompactBlockRange {
        return Int(self.start.height) ... Int(self.end.height)
    }
    
}

extension Array where Element == CompactBlock {
    func asZcashCompactBlocks() -> [ZcashCompactBlock] {
        self.map { ZcashCompactBlock(compactBlock: $0) }
    }
    
}
