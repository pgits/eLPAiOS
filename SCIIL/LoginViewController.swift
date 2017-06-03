import Foundation
import UIKit
import Alamofire
import SQLite
import UserNotifications
import Crashlytics
import Fabric
import Answers

class LoginViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet var serverTextField: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var internetStatus: UIImageView!
    @IBOutlet var rememberMe: UISwitch!
    @IBOutlet var rememberMeLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    
    // loading
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    
    var serversList = [String]()
    let serverPickerView = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        rememberMeLabel.text = Translator.getLangValue(key: "remember")
        loginButton.setTitle(Translator.getLangValue(key: "login"), for: .normal)
        self.title = Translator.getLangValue(key: "app_name")
        self.addNavigationButtons()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(LoginViewController.internetCheck), userInfo: nil, repeats: true)
        
        if (Reachability.isConnectedToNetwork() == true) {
            internetStatus.image = UIImage(named: "Connected_64px")
        }else{
            internetStatus.image = UIImage(named: "Disconnected_64px")
        }
        
//        self.username.text = "admin"
//        self.password.text = "sciil"

        //close keyboard on taping anywhere
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func internetCheck() {
        if (Reachability.isConnectedToNetwork() == true) {
            internetStatus.image = UIImage(named: "Connected_64px")
        }else{
            internetStatus.image = UIImage(named: "Disconnected_64px")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.stopActivityIndicatory()
        view.endEditing(true)
        
        if(self.rememberMe.isOn != true){
            self.password.text = ""
            self.rememberMe.setOn(false, animated: false)
        }
        
        if(Translator.checkIfKeyExist(key: "login_save_values") == true) {
            if(Int(Config.DEFAULTS.string(forKey: "login_remember_me")!) == 1){
                self.username.text = Config.DEFAULTS.string(forKey: "login_username")
                self.password.text = Config.DEFAULTS.string(forKey: "login_password")
                self.rememberMe.setOn(true, animated: false)
            }else{
                self.username.text = Config.DEFAULTS.string(forKey: "login_username")
            }
        }
        
        self.rememberMeLabel.text = Translator.getLangValue(key: "remember")
        self.loginButton.setTitle(Translator.getLangValue(key: "login"), for: .normal)
        self.title = Translator.getLangValue(key: "app_name")
        self.addNavigationButtons()
        if(Translator.checkIfKeyExist(key: "remember_me") == true) {
            if(Int(Config.DEFAULTS.string(forKey: "remember_me")!) == 1) {
                self.performSegue(withIdentifier: "AuditView", sender: nil)
            }
        }
        //setupSiren()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - Add custom buttons to navigation bar
    func addNavigationButtons() {
        // filter button
        let settingsButton:UIButton = UIButton(type: UIButtonType.custom) as UIButton
        settingsButton.addTarget(self, action: #selector(openSettings), for: UIControlEvents.touchUpInside)
        settingsButton.setTitle(Translator.getLangValue(key: "settings"), for: UIControlState.normal)
        settingsButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        settingsButton.sizeToFit()
        let customSettingsButton:UIBarButtonItem = UIBarButtonItem(customView: settingsButton)
        navigationItem.rightBarButtonItems = [customSettingsButton]
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        // Do any additional setup after loading the view.
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func openSettings(){
//        self.performSegue(withIdentifier: "settingsView", sender: nil)
        self.performSegue(withIdentifier: "newSettingsView", sender: nil)
    }
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        var dashboardLink: String!
        var documentationLink: String!
        
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        var moduleID:String!
        if(Translator.checkIfKeyExist(key: "profileID")){
            moduleID = Config.DEFAULTS.string(forKey: "profileID")!
            if let profile = try! db.pluck(PROFILE_DB.TABLE.filter(PROFILE_DB.ModuleID == moduleID)) {
                dashboardLink = profile[PROFILE_DB.DashboardLink]
                documentationLink = profile[PROFILE_DB.DocumentationLink]
                Config.DEFAULTS.set(profile[PROFILE_DB.WebServiceLink], forKey: "WS_URL")
                self.showActivityIndicatory(uiView: self.view)
                if let myLoginName = username.text {
                    Answers.logCustomEvent(withName: "login UserName", customAttributes: ["username":myLoginName])
                }
                Answers.logCustomEvent(withName: "profile ", customAttributes: ["dashboardLink":dashboardLink])
                
                WS.LOGIN_SERVICE.doLogin(username: username.text!, password: password.text!, module: moduleID, dashboardLink: dashboardLink, documentationLink: documentationLink) { (ResultCode :Int, errorMessage :String) in
                    if(ResultCode == 0){
                        self.removeAuditorsAndMachines()
                        Config.DEFAULTS.set(self.rememberMe.isOn, forKey: "remember_me")
                        Config.DEFAULTS.set("true", forKey: "firstLogin")
                        
                        if(self.rememberMe.isOn == true){
                            Config.DEFAULTS.set("true", forKey: "login_save_values")
                            Config.DEFAULTS.set(self.rememberMe.isOn, forKey:"login_remember_me")
                            Config.DEFAULTS.set(self.username.text, forKey: "login_username")
                            Config.DEFAULTS.set(self.password.text, forKey: "login_password")
                        }else{
                            Config.DEFAULTS.set(self.rememberMe.isOn, forKey:"login_remember_me")
                            Config.DEFAULTS.set("true", forKey: "login_save_values")
                            Config.DEFAULTS.set(self.username.text, forKey: "login_username")
                        }
                        
                        self.performSegue(withIdentifier: "AuditView", sender: nil)

                    }else{
                        self.stopActivityIndicatory()
                        let alertController = UIAlertController(title: Translator.getLangValue(key: "error"), message: Translator.getLangValue(key: "wrong_password"), preferredStyle: .alert)
                        let okAction = UIAlertAction(title: Translator.getLangValue(key: "ok"), style: .default, handler: nil)
                    
                        alertController.addAction(okAction)
                        if let myLoginName = self.username.text {
                            Answers.logCustomEvent(withName: "login Failed", customAttributes: ["username":myLoginName])
                        }

                        self.present(alertController, animated: true, completion: nil)
                    }
                    if(ResultCode == 15) {
                        self.stopActivityIndicatory()
                        self.showProblemConnecting()
                    }
                }
                if (Reachability.isConnectedToNetwork() == false) {
                    self.stopActivityIndicatory()
                    self.showConnectionErrorAlert()
                }
            }else{
                self.showConnectionErrorAlert()
            }
        }else{
            self.showConnectionErrorAlert()
        }
    }
    
    func showActivityIndicatory(uiView: UIView) {
        
        container.frame = uiView.frame
        container.center = uiView.center
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:0.0)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2,
                                y: loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.startAnimating()
    }
    
    func stopActivityIndicatory() {
        actInd.stopAnimating()
        container.removeFromSuperview()
    }
    
    func removeAuditorsAndMachines() {
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        let auditorsList = Table("auditorsList")
        let machinesList = Table("machinesList")
        
        do {
            if try db.run(auditorsList.delete()) > 0 {
                print("deleted Auditors list")
            } else {
                print("Auditors list not found")
            }
            
            if try db.run(machinesList.delete()) > 0 {
                print("deleted Machine List")
            } else {
                print("Machine List not found")
            }
            
            if try db.run(Login_DB.TABLE.delete()) > 0 {
                print("deleted Logins")
            } else {
                print("Logins not found")
            }
            
            if try db.run(Audit_DB.TABLE.delete()) > 0 {
                print("deleted Audits")
            } else {
                print("Audits not found")
            }
            
            Config.DEFAULTS.removeObject(forKey: "dateFromTimeStamp")
            Config.DEFAULTS.removeObject(forKey: "dateToTimeStamp")
            Config.DEFAULTS.removeObject(forKey: "user_filter")
            Config.DEFAULTS.removeObject(forKey: "machine_filter")
            
        } catch {
            print("delete failed: \(error)")
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = Translator.getLangValue(key: "back")
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    func anImportantUserAction(title:String, key:String, value:String) {
        
        // TODO: Move this method and customize the name and parameters to track your key metrics
        //       Use your own string attributes to track common values over time
        //       Use your own number attributes to track median value over time
        Answers.logCustomEvent(withName: title, customAttributes: [key:value])
    }
    
    func setupSiren() {
        let siren = Siren.sharedInstance
        
        // Optional
        siren.delegate = self
        
        // Optional
        siren.debugEnabled = true
        
        // Optional
        siren.appName = "SCIIL eLPA"
        
        // Optional - Defaults to .Option
        //        siren.alertType = .Option // or .Force, .Skip, .None
        
        // Optional - Can set differentiated Alerts for Major, Minor, Patch, and Revision Updates (Must be called AFTER siren.alertType, if you are using siren.alertType)
        siren.majorUpdateAlertType = .option
        siren.minorUpdateAlertType = .option
        siren.patchUpdateAlertType = .option
        siren.revisionUpdateAlertType = .option
        
        // Optional - Sets all messages to appear in Spanish. Siren supports many other languages, not just English and Russian.
        //        siren.forceLanguageLocalization = .Russian
        
        // Optional - Set this variable if your app is not available in the U.S. App Store. List of codes: https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Appendices/AppStoreTerritories.html
        //        siren.countryCode = ""
        
        // Optional - Set this variable if you would only like to show an alert if your app has been available on the store for a few days. The number 5 is used as an example.
        //        siren.showAlertAfterCurrentVersionHasBeenReleasedForDays = 5
        
        // Required
        siren.checkVersion(checkType: .immediately)
    }
}


extension LoginViewController: SirenDelegate
{
    func sirenDidShowUpdateDialog(alertType: SirenAlertType) {
        print(#function, alertType)
    }
    
    func sirenUserDidCancel() {
        print(#function)
    }
    
    func sirenUserDidSkipVersion() {
        print(#function)
    }
    
    func sirenUserDidLaunchAppStore() {
        print(#function)
    }
    
    func sirenDidFailVersionCheck(error: NSError) {
        print(#function, error)
    }
    
    func sirenLatestVersionInstalled() {
        print(#function, "Latest version of app is installed")
    }
    
    // This delegate method is only hit when alertType is initialized to .none
    func sirenDidDetectNewVersionWithoutAlert(message: String) {
        print(#function, "\(message)")
    }
}

