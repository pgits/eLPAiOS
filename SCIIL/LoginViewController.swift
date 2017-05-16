import Foundation
import UIKit
import Alamofire
import SQLite
import UserNotifications

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
}
