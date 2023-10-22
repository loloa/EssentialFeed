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
 
        window?.rootViewController = UINavigationController(
            rootViewController: FeedUIComposer.feedComposedWith(
                feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                imageLoader: makeLocalImageLoaderWithRemoteFallback))
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error> {
        
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
//
//        remoteFeedLoader = RemoteLoader(url: remoteURL, client: httpClient, mapper: FeedItemMapper.map)
        //Creates a publisher that invokes a promise closure when the publisher emits an element.
        
        return httpClient
            .getPublisher(url: remoteURL)
            .tryMap(FeedItemMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    /*
     composition sandwitch
     [ side - effect]
     -pure function-
     [ side - effect ]
 
     */
    
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        
       // let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback { [httpClient] in
                httpClient.getPublisher(url: url)
                    .tryMap(FeedImageDataMapper.map)
                    .cache(to: localImageLoader, using: url)
            }
//                remoteImageLoader.loadImageDataPublisher(from: url)
//                    .cache(to: localImageLoader, using: url)
          
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


 
