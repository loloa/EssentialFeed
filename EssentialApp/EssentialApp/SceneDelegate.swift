//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by אליסה לשין on 02/10/2023.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite"))
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
            LocalFeedLoader(store: store, currentDate: Date.init)
        }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
                
        configureWindow()
    }
    
    func configureWindow() {
       
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
 
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        window?.rootViewController = UINavigationController(
            rootViewController: FeedUIComposer.feedComposedWith(
                feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                imageLoader: FeedImageDataLoaderWithFallbackComposite(
                    primary: localImageLoader,
                    fallback: FeedImageDataLoaderCacheDecorator(
                        decoratee: remoteImageLoader,
                        cache: localImageLoader))))
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error> {
        
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
        //Creates a publisher that invokes a promise closure when the publisher emits an element.
        return remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
}

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
        ImmediateWhenOnMainQueuScheduler()
    }
    
    struct ImmediateWhenOnMainQueuScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
 
        var now: Self.SchedulerTimeType { DispatchQueue.main.now }

        var minimumTolerance: Self.SchedulerTimeType.Stride { DispatchQueue.main.minimumTolerance }

        func schedule(options: Self.SchedulerOptions?, _ action: @escaping () -> Void) {
            
            guard Thread.isMainThread else {
               return DispatchQueue.main.schedule(options: options, action)
                
            }
            action()
            
        }

         
        func schedule(after date: Self.SchedulerTimeType, tolerance: Self.SchedulerTimeType.Stride, options: Self.SchedulerOptions?, _ action: @escaping () -> Void){
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }

         func schedule(after date: Self.SchedulerTimeType, interval: Self.SchedulerTimeType.Stride, tolerance: Self.SchedulerTimeType.Stride, options: Self.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
        
    }
}
