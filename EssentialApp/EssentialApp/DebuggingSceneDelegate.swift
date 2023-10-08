//
//  DebuggingSceneDelegate.swift
//  EssentialApp
//
//  Created by אליסה לשין on 08/10/2023.
//


#if DEBUG
import UIKit
import EssentialFeed

class DebuggingSceneDelegate: SceneDelegate {
    
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
 
       
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeRemoteClient() -> HTTPClient {
 
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
             return AlwaysFailingHTTPClient()
        }
        return super.makeRemoteClient()
       
    }
    
    
    private class AlwaysFailingHTTPClient: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() {}
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(.failure(NSError(domain: "offline", code: 0)))
            return Task()
        }
    }
}
#endif
