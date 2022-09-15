//
//  CompactBlockValidationInformation.swift
//  ZcashLightClientKit
//
//  Created by Francisco Gindre on 10/30/19.
//  Copyright © 2019 Electric Coin Company. All rights reserved.
//

import Foundation

extension CompactBlockProcessor {
    enum CompactBlockValidationError: Error {
        case validationFailed(height: BlockHeight)
        case failedWithError(_ error: Error?)
    }

    func compactBlockValidation() async throws {
        try Task.checkCancellation()
        
        setState(.validating)

        let result = rustBackend.validateCombinedChain(dbCache: config.cacheDb, dbData: config.dataDb, networkType: config.network.networkType)
        
        do {
            switch result {
            case 0:
                let error = CompactBlockValidationError.failedWithError(rustBackend.lastError())
                LoggerProxy.debug("block scanning failed with error: \(String(describing: error))")
                throw error
                
            case ZcashRustBackendWeldingConstants.validChain:
                if Task.isCancelled {
                    setState(.stopped)
                    LoggerProxy.debug("Warning: compactBlockValidation cancelled")
                }
                LoggerProxy.debug("validateChainFinished")
                break
                
            default:
                let error = CompactBlockValidationError.validationFailed(height: BlockHeight(result))
                LoggerProxy.debug("block scanning failed with error: \(String(describing: error))")
                throw error
            }
        } catch {
            guard let validationError = error as? CompactBlockValidationError else {
                LoggerProxy.error("Warning: compactBlockValidation returning generic error: \(error)")
                return
            }
            
            switch validationError {
            case .validationFailed(let height):
                LoggerProxy.debug("chain validation at height: \(height)")
                validationFailed(at: height)
            case .failedWithError(let err):
                guard let validationFailure = err else {
                    LoggerProxy.error("validation failed without a specific error")
                    self.fail(CompactBlockProcessorError.generalError(message: "validation failed without a specific error"))
                    return
                }
                
                throw validationFailure
            }
        }
    }
}
