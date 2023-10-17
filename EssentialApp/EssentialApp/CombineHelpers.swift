//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by אליסה לשין on 16/10/2023.
//

import Foundation
import Combine
import EssentialFeed


//MARK: --

public extension Publisher where Output == Data {
    
    func cache(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data: data, for: url)
        }).eraseToAnyPublisher()
    }
}

private extension FeedImageDataCache {
    
    func saveIgnoringResult(data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}

public extension FeedImageDataLoader {
    
    typealias Publisher = AnyPublisher<Data, Error>
    
    func loadImageDataPublisher(from url: URL) -> Publisher {
        
        var task: FeedImageDataLoaderTask?
        
        return Deferred {
            Future { promise in
                task = self.loadImageData(from: url, completion: promise)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() } )
        .eraseToAnyPublisher()
    }
}
// MARK: ---
public extension FeedLoader {
    
    typealias Publisher = AnyPublisher<[FeedImage], Error>
    func loadPublisher() -> Publisher {
        
        Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

private extension FeedCache {
    
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed, comletion: { _ in })
    }
}


extension Publisher {
    
    func fallback(to fallbackPublisher: @escaping() -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in  fallbackPublisher() }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == [FeedImage] {
    
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        
        handleEvents(receiveOutput: cache.saveIgnoringResult)
            .eraseToAnyPublisher()
    }
    
}

extension Publisher {
    
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        
        receive(on: DispatchQueue.immediateWhenOnMainQueuScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    
    static var immediateWhenOnMainQueuScheduler: ImmediateWhenOnMainQueuScheduler {
        ImmediateWhenOnMainQueuScheduler.shared
    }
    
    struct ImmediateWhenOnMainQueuScheduler: Scheduler {
        
        
        private static let key = DispatchSpecificKey<UInt8>()
        private static let value = UInt8.max
        
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        static let shared = Self()
        
        private init() {
            DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
        }
        
        var now: Self.SchedulerTimeType { DispatchQueue.main.now }
        
        var minimumTolerance: Self.SchedulerTimeType.Stride { DispatchQueue.main.minimumTolerance }
        
        func schedule(options: Self.SchedulerOptions?, _ action: @escaping () -> Void) {
            
            guard isMainQueue() else {
                return DispatchQueue.main.schedule(options: options, action)
                
            }
            action()
        }
        
        private func isMainQueue() -> Bool {
            return DispatchQueue.getSpecific(key: Self.key) == Self.value
        }
        
        func schedule(after date: Self.SchedulerTimeType, tolerance: Self.SchedulerTimeType.Stride, options: Self.SchedulerOptions?, _ action: @escaping () -> Void){
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        
        func schedule(after date: Self.SchedulerTimeType, interval: Self.SchedulerTimeType.Stride, tolerance: Self.SchedulerTimeType.Stride, options: Self.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
        
    }
}
