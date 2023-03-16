//
//  SynchronizerNonAsync.swift
//  
//
//  Created by Michal Fousek on 16.03.2023.
//

import Combine
import Foundation

public protocol SynchronizerNonAsync {
    var stateStream: AnyPublisher<SynchronizerState, Never> { get }

    var latestState: SynchronizerState { get }

    var eventStream: AnyPublisher<SynchronizerEvent, Never> { get }

    var connectionState: ConnectionState { get }

    func prepare(
        with seed: [UInt8]?,
        viewingKeys: [UnifiedFullViewingKey],
        walletBirthday: BlockHeight,
        completion: @escaping (Result<Initializer.InitializationResult, Error>) -> Void
    )

    func prepare(
        with seed: [UInt8]?,
        viewingKeys: [UnifiedFullViewingKey],
        walletBirthday: BlockHeight
    ) -> AnyPublisher<Initializer.InitializationResult, Error>

    func start(retry: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func start(retry: Bool) -> AnyPublisher<Void, Error>

    func stop()
}
