//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by אליסה לשין on 02/10/2023.
//
import os
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
    
    private lazy var logger: Logger = Logger(subsystem: "com.essential.CaseStudy", category: "min")
     
    private lazy var store: FeedStore & FeedImageDataStore = {
        
        do {
            return try CoreDataFeedStore(
                storeURL: NSPersistentContainer
                    .defaultDirectoryURL()
                    .appendingPathComponent("feed-store.sqlite"))
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return NullStore()
        }
        
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
        selection: showComments(for:)))
    
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
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
 
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func showComments(for image: FeedImage) {
        
        let remoteURL = ImageCommentsEndPoints.get(image.id).url(baseURL: baseURL)
        //baseURL.appending(path: "/v1/image/\(image.id)/comments")
        
        let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: remoteURL))
        navigationController.pushViewController(comments, animated: true)
    }
    
    private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        
        return { [httpClient, logger] in
 
            return httpClient
                .getPublisher(url: url)
                .logElapsedTime(url: url, logger: logger)
                .logErrors(url: url, logger: logger)
                .tryMap(ImageCommentsMapper.map).eraseToAnyPublisher()
                .eraseToAnyPublisher()
                 
        }
    }
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
 
          makeRemoteFeedLoader()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteFeedLoader(after: FeedImage? = nil) ->  AnyPublisher<[FeedImage], Error> {
 
            let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)
            
            return httpClient
            .getPublisher(url: url)
            .tryMap(FeedItemMapper.map)
            .eraseToAnyPublisher()
      }
 
    private func makeRemoteLoaderMoreLoader(items: [FeedImage], last: FeedImage?) ->  AnyPublisher<Paginated<FeedImage>, Error> {
 
         makeRemoteFeedLoader(after: last)
                .map { newItems in
                    (items + newItems, newItems.last)
                }
                .map(makePage)
//                .simulateDelay()
//                .flatMap { _ in
//                    Fail(error: NSError())
//                }
                .caching(to: localFeedLoader)
     }
    
    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }
    
    private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(items: items, loadMorePublisher: last.map { lastItem in
            { self.makeRemoteLoaderMoreLoader(items: items, last: lastItem)}
         })
     }
   
     /*
     composition sandwitch
     [ side - effect]
     -pure function-
     [ side - effect ]
 
     */
    
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        
       // let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        
        let client = HTTPClientProfilingDecorator(decoratee: httpClient, logger: logger)
        
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .logCacheMisses(url: url, logger: logger)
            .fallback {
                client.getPublisher(url: url)
                    .tryMap(FeedImageDataMapper.map)
                    .cache(to: localImageLoader, using: url)
            }
    }
}

 
extension Publisher {
 
    func simulateDelay() -> AnyPublisher<Output, Failure> {
        
        delay(for: 2, scheduler: DispatchSerialQueue.main)
            .eraseToAnyPublisher()
    }
    
    func logCacheMisses(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
         return handleEvents(
             receiveCompletion: { result in
                if case .failure = result {
                    logger.trace("**********************   Cache miss loading url: \(url))")
                }
             }
        ).eraseToAnyPublisher()
    }

    
    func logErrors(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
         return handleEvents(
             receiveCompletion: { result in
                
                if case let .failure(error) = result {
                    logger.trace("Publisher Failed loading url: \(url), error \(error.localizedDescription)")
                }
             }
        ).eraseToAnyPublisher()
    }
    
    func logElapsedTime(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
       var startTime = CACurrentMediaTime()
        
        return handleEvents(
            receiveSubscription: {  _ in
                
            startTime = CACurrentMediaTime()
            logger.trace("Publisher Started loading url: \(url)")
        },
            receiveCompletion: { result in
 
                let elapsed = CACurrentMediaTime() - startTime
                logger.trace("Publisher Finished loading url: \(url), elapsed \(elapsed)")
                
            }
        ).eraseToAnyPublisher()
    }
}

 
 
//
//public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>
//
//public extension RemoteImageCommentsLoader {
//
//    convenience init (url: URL, client: HTTPClient) {
//        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
//    }
//}


