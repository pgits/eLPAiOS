import Foundation
import UIKit

class Alerts {
    class func showAlert(controller: UIViewController) {
        // create the alert
        let alert = UIAlertController(title: "My Title", message: "This is my message.", preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        controller.present(alert, animated: true, completion: nil)
    }
}
extension FilterViewController {
    func showAlertInternetError() {
        // create the alert
        let alert = UIAlertController(title: Translator.getLangValue(key: "no_internet_connection"), message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "ok"), style: UIAlertActionStyle.default, handler: getBack))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func getBack(alert: UIAlertAction!) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
extension ManagePageViewController {
    func showAlertServerError() {
        // create the alert
        let alert = UIAlertController(title: Translator.getLangValue(key: "can_not_open_audit_offline"), message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "ok"), style: UIAlertActionStyle.default, handler: getBack))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertNoQuestions() {
        // create the alert
        let alert = UIAlertController(title: Translator.getLangValue(key: "can_not_open_audit_no_questions"), message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "ok"), style: UIAlertActionStyle.default, handler: getBack))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func getBack(alert: UIAlertAction!) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func showAlertOnErrorSaving() {
        // create the alert
        let alert = UIAlertController(title: Translator.getLangValue(key: "error_saving_answers"), message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "ok"), style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController {
    func showConnectionErrorAlert() {
        let alert = UIAlertController(title: Translator.getLangValue(key: "connection_error"), message: Translator.getLangValue(key: "could_not_download_profiles"), preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "settings"), style: UIAlertActionStyle.default, handler: openSettingsAlert))

        alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "close_app"), style: UIAlertActionStyle.destructive, handler: closeApp))
        
        alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "cancel"), style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func closeApp(alert: UIAlertAction!) {
        exit(0)
    }
    
    func openSettingsAlert(alert: UIAlertAction!) {
        self.performSegue(withIdentifier: "newSettingsView", sender: nil)
    }
    
    func showProblemConnecting() {
        // create the alert
        let alert = UIAlertController(title: Translator.getLangValue(key: "server_problem"), message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "ok"), style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}

extension AuditViewController {
    func showLogoutAlert() {
        let alert = UIAlertController(title: Translator.getLangValue(key: "alert_choose_exit_option"), message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "logout"), style: UIAlertActionStyle.default, handler: alertLogout))
        
        alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "close_app"), style: UIAlertActionStyle.default, handler: closeApp))
        
        alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "cancel"), style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func closeApp(alert: UIAlertAction!) {
        exit(0)
    }
    
    func alertLogout(alert: UIAlertAction!) {
        Config.DEFAULTS.set(0, forKey: "remember_me")
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
