//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by אליסה לשין on 16/10/2023.
//

import Foundation
import Combine
import EssentialFeed

public extension Paginated {
    
    init(items: [Item], loadMorePublisher: (() -> AnyPublisher<Self, Error>)?) {
        
        self.init(items: items, loadMore: loadMorePublisher.map { publisher in
            return { completion in
                
                publisher().subscribe(Subscribers.Sink(receiveCompletion: { result in
                    
                    if case let .failure(error) = result {
                        completion(.failure(error))
                    }
                     
                }, receiveValue: { result in
                    completion(.success(result))
                }))
            }
        })
    }
    var loadMorePublisher: (() -> AnyPublisher<Self, Error>)? {
        guard let loadMore = loadMore else { return nil }
        
        return {
            Deferred {
                Future(loadMore)
            }.eraseToAnyPublisher()
        }
    }
    
}

public extension HTTPClient {
    
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>
    
    func getPublisher(url: URL) -> Publisher {
        
        var task: HTTPClientTask?
        
        return Deferred {
            Future { promise in
                task = self.get(from: url, completion: promise)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() } )
        .eraseToAnyPublisher()
    }
}

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
        try? save(data, for: url)
    }
}

public extension FeedImageDataLoader {
    
    typealias Publisher = AnyPublisher<Data, Error>
    
    func loadImageDataPublisher(from url: URL) -> Publisher {
 
        return Deferred {
            Future { promise in
                 
                promise(Result{
                    try self.loadImageData(from: url)
                })
             }
        }
         .eraseToAnyPublisher()
    }
}
// MARK: ---
public extension LocalFeedLoader {
    
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
    
    func saveIgnoringResult(_ page: Paginated<FeedImage>) {
        saveIgnoringResult(page.items)
    }
}


extension Publisher {
    
    func fallback(to fallbackPublisher: @escaping() -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in  fallbackPublisher() }.eraseToAnyPublisher()
    }
}

extension Publisher {
    
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure>  where Output == [FeedImage] {
        
        handleEvents(receiveOutput: cache.saveIgnoringResult)
            .eraseToAnyPublisher()
    }
    
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure>  where Output == Paginated<FeedImage> {
        
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
