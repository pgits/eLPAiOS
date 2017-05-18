import UIKit
import Fabric
import Crashlytics
import UserNotifications
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.backgroundColor = UIColor(red:0.00, green:0.30, blue:0.45, alpha:1.0)
        Translator.setLangValues()
        
        let storyboard = grabStoryboard()
        
        // display storyboard
        self.window?.rootViewController = storyboard.instantiateInitialViewController()
        self.window?.makeKeyAndVisible()

//        Fabric.with([Crashlytics.self])
        removeOldImages()
        
        application.registerUserNotificationSettings(
            UIUserNotificationSettings(
                types:[.alert, .sound, .badge],
                categories: nil
            )
        )
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            center.requestAuthorization(options: options) { (granted, error) in
                if granted {
                    application.registerForRemoteNotifications()
                }
            }
        } else {
            // Fallback on earlier versions
        }

        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print(token)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func grabStoryboard() -> UIStoryboard
    {
        // determine screen size
        let screenHeight = UIScreen.main.bounds.size.height
        var storyboard: UIStoryboard! = nil
        
        switch (screenHeight)
        {
        // iPhone 4s
        case 480:
            storyboard = UIStoryboard(name: "Main-4s", bundle: nil)
        // iPhone SE
        case 568:
            storyboard = UIStoryboard(name: "Main-SE", bundle: nil)
        // iPhone 6
        case 667:
            storyboard = UIStoryboard(name: "Main", bundle: nil)
        // iPhone 6 Plus
        case 736:
            storyboard = UIStoryboard(name: "Main-Plus", bundle: nil)
        default:
            // iPhone 6
            storyboard = UIStoryboard(name: "Main", bundle: nil)
        }
        
        return storyboard
    }
    
    func removeOldImages() {
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                for fileName in fileNames {
                    let filePath = documentsUrl.appendingPathComponent(fileName)?.path
                    if(fileName.hasSuffix(".jpg")) {
                        let attributes = try fileManager.attributesOfItem(atPath: filePath!)
                        let fileCreationDate = attributes[FileAttributeKey.creationDate] as! Date?
                        if(Date().days(from: fileCreationDate!) > 29) {
                            try fileManager.removeItem(atPath: filePath!)
                        }
                    }
                }
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
}

