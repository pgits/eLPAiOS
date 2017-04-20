import Foundation
import UIKit
import SQLite

struct Config {
    static let WS_URL = "https://www.sciil.lt:50273"
    static let DB_FILE = "data.db"
    static let PATH = NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true
        ).first!
    static let DEFAULTS = UserDefaults.standard
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
}

struct Colors {
    static let GREEN = UIColor(red:0.03, green:0.88, blue:0.63, alpha:1.0)
    static let RED = UIColor(red:1.00, green:0.28, blue:0.44, alpha:1.0)
}

struct StatusColors {
    static let GREEN = UIColor(red:0.00, green:0.75, blue:0.65, alpha:1.0)
    static let YELLOW = UIColor(red:1.00, green:0.72, blue:0.30, alpha:1.0)
    static let RED = UIColor(red:0.92, green:0.25, blue:0.40, alpha:1.0)
}

struct StatusIcons {
    static let GREEN = "green_icon-60"
    static let YELLOW = "yellow_icon-60"
    static let RED = "purple_icon-60"
}

struct STATUS {
    static let STARTED = "started"
    static let OVERDUE = "overdue"
    static let PLANNED = "planned"
    static let NOT_FINISHED = "not_finished"
    static let NOT_SYNCED = "not_synced"
}
struct STATUS_TEXT {
    static var STARTED = Translator.getLangValue(key: "status_started")
    static var OVERDUE = Translator.getLangValue(key: "status_overdue")
    static var PLANNED = Translator.getLangValue(key: "status_planned")
    static var NOT_FINISHED = Translator.getLangValue(key: "status_not_finished")
    static var NOT_SYNCED = Translator.getLangValue(key: "status_not_synced")
}
struct WS {
    static let AUDIT_SERVICE = auditService()
    static let LOGIN_SERVICE = loginService()
    static let AUDITORS_SERVICE = auditorsListService()
    static let WORKSTATION_SERVICE = workstationService()
    static let LANGUAGE_SERVICE = langService()
}

struct APP_FLAVOR {
    //static let APP = "sciil"
    static let APP = "adient"
}

struct Adient {
    static let URL = "https://elpa.ga.adient.com:50263"
}
