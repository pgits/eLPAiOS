import Foundation
import UIKit
import UserNotifications

class NotificationHelper {
    class func uploadAudit() {
        //Set the content of the notification
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.body = Translator.getLangValue(key: "uploading_audit")
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "alarm"
            content.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
            
            //Set the trigger of the notification -- here a timer.
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 1.0,
                repeats: false)
            
            //Set the request for the notification from the above
            let request = UNNotificationRequest(
                identifier: "uploading_audit",
                content: content,
                trigger: trigger
            )

            //Add the notification to the currnet notification center
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print(error)
                } else {
                    print(Translator.getLangValue(key: "uploading_audit"))
                }
            }
        } else {
            let notification = UILocalNotification() // create a new reminder notification
            notification.alertBody = Translator.getLangValue(key: "uploading_audit")
            notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
            notification.fireDate = Date()
            notification.soundName = UILocalNotificationDefaultSoundName // play default sound
            notification.userInfo = ["title": "uploading_audit"] // assign a unique identifier to the notification that we can use to retrieve it later
            notification.category = "alarm"
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    class func uploadAuditPhoto() {
        //Set the content of the notification
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.body = Translator.getLangValue(key: "uploading_photos")
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "alarm"
            content.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
            
            //Set the trigger of the notification -- here a timer.
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 1.0,
                repeats: false)
            
            //Set the request for the notification from the above
            let request = UNNotificationRequest(
                identifier: "uploading_photos",
                content: content,
                trigger: trigger
            )

            //Add the notification to the currnet notification center
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print(error)
                } else {
                    print(Translator.getLangValue(key: "uploading_photos"))
                }
            }
        } else {
            let notification = UILocalNotification() // create a new reminder notification
            notification.alertBody = Translator.getLangValue(key: "uploading_photos")
            notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
            notification.fireDate = Date()
            notification.soundName = UILocalNotificationDefaultSoundName // play default sound
            notification.userInfo = ["title": "uploading_photos"] // assign a unique identifier to the notification that we can use to retrieve it later
            notification.category = "alarm"
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    class func cantSavePhoto() {
        //Set the content of the notification
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.body = Translator.getLangValue(key: "can_not_save_photo")
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "alarm"
            content.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
            
            //Set the trigger of the notification -- here a timer.
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 1.0,
                repeats: false)
            
            //Set the request for the notification from the above
            let request = UNNotificationRequest(
                identifier: "can_not_save_photo",
                content: content,
                trigger: trigger
            )
            
            //Add the notification to the currnet notification center
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print(error)
                } else {
                    print(Translator.getLangValue(key: "can_not_save_photo"))
                }
            }
        } else {
            let notification = UILocalNotification() // create a new reminder notification
            notification.alertBody = Translator.getLangValue(key: "can_not_save_photo")
            notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
            notification.fireDate = Date()
            notification.soundName = UILocalNotificationDefaultSoundName // play default sound
            notification.userInfo = ["title": "can_not_save_photo"] // assign a unique identifier to the notification that we can use to retrieve it later
            notification.category = "alarm"
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    class func finishedAuditUploading() {
        //Set the content of the notification
        if #available(iOS 10.0, *) {
            NotificationHelper.removeNotificationByIdentifer(identifer: "uploading_photos")
            NotificationHelper.removeNotificationByIdentifer(identifer: "uploading_audit")
            let content = UNMutableNotificationContent()
            content.body = Translator.getLangValue(key: "finished_uploading")
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "alarm"
            content.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
            
            //Set the trigger of the notification -- here a timer.
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 1.0,
                repeats: false)
            
            //Set the request for the notification from the above
            let request = UNNotificationRequest(
                identifier: "finished_uploading",
                content: content,
                trigger: trigger
            )

            //Add the notification to the currnet notification center
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print(error)
                } else {
                    print(Translator.getLangValue(key: "finished_uploading"))
                }
            }
        } else {
            let notification = UILocalNotification() // create a new reminder notification
            notification.alertBody = Translator.getLangValue(key: "finished_uploading")
            notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
            notification.fireDate = Date()
            notification.soundName = UILocalNotificationDefaultSoundName // play default sound
            notification.userInfo = ["title": "finished_uploading"] // assign a unique identifier to the notification that we can use to retrieve it later
            notification.category = "alarm"
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    class func finishedPhotoUploading() {
        //Set the content of the notification
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.body = Translator.getLangValue(key: "finished_uploading_photos")
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "alarm"
            content.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
            
            //Set the trigger of the notification -- here a timer.
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 1.0,
                repeats: false)
            
            //Set the request for the notification from the above
            let request = UNNotificationRequest(
                identifier: "finished_uploading_photos",
                content: content,
                trigger: trigger
            )

            //Add the notification to the currnet notification center
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print(error)
                } else {
                    print(Translator.getLangValue(key: "finished_uploading_photos"))
                }
            }
        } else {
            let notification = UILocalNotification() // create a new reminder notification
            notification.alertBody = Translator.getLangValue(key: "finished_uploading_photos")
            notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
            notification.fireDate = Date()
            notification.soundName = UILocalNotificationDefaultSoundName // play default sound
            notification.userInfo = ["title": "finished_uploading_photos"] // assign a unique identifier to the notification that we can use to retrieve it later
            notification.category = "alarm"
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    class func removeNotificationByIdentifer(identifer:String) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifer])
        } else {
            // Fallback on earlier versions
        }
    }
}
