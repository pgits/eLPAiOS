//
//  AuditViewController.swift
//  SCIIL
//
//  Created by Eugenijus Denisov on 03/11/16.
//  Copyright © 2016 Eugenijus Denisov. All rights reserved.
//

import UIKit
import SQLite
import Crashlytics

class AuditViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    // MARK: - Strings
    let cellReuseIdentifier = "CustomAuditsTableCell"
    
    var auditID:String!
    
    @IBOutlet var tableView: UITableView!
    
    var usersList = [String]()
    var auditIDarray = [String]()
    var auditStartedUserID = [String]()
    var usersStartedList = [String]()
    var auditUserID = [String]()
    var status = [String]()
    var statusText = [String]()
    var workstation = [String]()
    
    var planned = [String]()
    
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    
    var connection:UIBarButtonItem!
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    // MARK: - Main function
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(AuditViewController.loadList),name:NSNotification.Name(rawValue: "load"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AuditViewController.noAudits),name:NSNotification.Name(rawValue: "showNoAudits"), object: nil)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        self.addBackground()
        self.tableView.register(CustomAuditsTableCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.addNavigationButtons()
        
//        self.title = Translator.getLangValue(key: "title_activity_audit_list")
        self.title = ""
    }
    
    func loadList(){
        //load data here
        self.getUsers()
        self.tableView.reloadData()
    }
    
    func noAudits() {
        TableViewHelper.EmptyMessage(message: Translator.getLangValue(key: "no_planned_audits"), tableView: self.tableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CustomAuditsTableCell
        
        //texts
        cell.userText.text = self.usersList[indexPath.row]
        cell.workstationText.text = self.workstation[indexPath.row]
        cell.plannedDate.text = self.planned[indexPath.row]
        cell.statusText.text = self.statusText[indexPath.row]
        //colors of some text
        cell.plannedText.textColor = setColor(status: self.status[indexPath.row])
        cell.plannedDate.textColor = setColor(status: self.status[indexPath.row])
        cell.statusText.textColor = setColor(status: self.status[indexPath.row])
        
        // change status image
        cell.statusImage.image = UIImage(named: setImage(status: self.status[indexPath.row]))
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        if let login = try! db.pluck(Login_DB.TABLE) {
            if(status[indexPath.row] == STATUS.STARTED || status[indexPath.row] == STATUS.NOT_FINISHED){
                if(login[Login_DB.IDUser] == auditStartedUserID[indexPath.row]){
                    auditID = auditIDarray[indexPath.row]
                    if (Reachability.isConnectedToNetwork() == true) {
                        performSegue(withIdentifier: "openAudit", sender: nil)
                    }else{
                        do {
                            if let _ = try db.pluck(Answer_DB.TABLE.filter(Answer_DB.IDLPAAudit == auditID)) {
                                performSegue(withIdentifier: "openAudit", sender: nil)
                            }else{
                                let alert = UIAlertController(title: Translator.getLangValue(key: "error"), message: Translator.getLangValue(key: "no_internet_connection"), preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "cancel"), style: UIAlertActionStyle.default, handler: nil))
                                
                                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                            }
                        }catch {
                            let alert = UIAlertController(title: Translator.getLangValue(key: "error"), message: Translator.getLangValue(key: "no_internet_connection"), preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "cancel"), style: UIAlertActionStyle.default, handler: nil))
                            
                            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                        }
                    }
                }else{
                    let alertMessage = Translator.getLangValue(key: "audit_started_by") + " \(usersStartedList[indexPath.row])"
                    let alert = UIAlertController(title: alertMessage, message: "", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "cancel"), style: UIAlertActionStyle.default, handler: nil))
                    
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }else{
                auditID = auditIDarray[indexPath.row]
                if (Reachability.isConnectedToNetwork() == true) {
                    performSegue(withIdentifier: "openAudit", sender: nil)
                }else{
                    do {
                        if let _ = try db.pluck(Answer_DB.TABLE.filter(Answer_DB.IDLPAAudit == auditID)) {
                            performSegue(withIdentifier: "openAudit", sender: nil)
                        }
                    }catch{
                        let alert = UIAlertController(title: Translator.getLangValue(key: "error"), message: Translator.getLangValue(key: "no_internet_connection"), preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "cancel"), style: UIAlertActionStyle.default, handler: nil))
                        
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell  = tableView.cellForRow(at: indexPath)
        cell!.contentView.backgroundColor = UIColor(red:0.02, green:0.19, blue:0.29, alpha:1.0)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell  = tableView.cellForRow(at: indexPath)
        cell!.contentView.backgroundColor = .clear
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(auditIDarray.count > 0){
            return 1
        }else{
            if(!Translator.checkIfKeyExist(key: "firstLogin")) {
                TableViewHelper.EmptyMessage(message: Translator.getLangValue(key: "no_planned_audits"), tableView: self.tableView)
            }
            return 0
        }
    }
    
    // MARK: - Custom functions
    func openDocumentation(){
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        
        var url: URL!
        if let dashboard = try! db.pluck(Login_DB.TABLE) {
            var makeURL = "\(dashboard[Login_DB.DocumentationLink])"
            if(makeURL.hasHTTP()) {
                url = URL(string: makeURL)
            }else{
                makeURL = "http://\(dashboard[Login_DB.DocumentationLink])"
                url = URL(string: makeURL)
            }
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url!)
        }
    }
    
    func openDashboard(){
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        
        var url: URL!
        if let dashboard = try! db.pluck(Login_DB.TABLE) {
            var makeURL = "\(dashboard[Login_DB.DashboardLink])"
            if(makeURL.hasHTTP()) {
                url = URL(string: makeURL)
            }else{
                makeURL = "http://\(dashboard[Login_DB.DashboardLink])"
                url = URL(string: makeURL)
            }
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url!)
        }
    }
    
    func setColor (status:String) -> UIColor {
        if(status == STATUS.NOT_FINISHED){
            return StatusColors.YELLOW
        }
        if(status == STATUS.OVERDUE){
            return StatusColors.RED
        }
        if(status == STATUS.PLANNED){
            return StatusColors.GREEN
        }
        if(status == STATUS.STARTED){
            return StatusColors.YELLOW
        }
        if(status == STATUS.NOT_SYNCED) {
            return StatusColors.RED
        }
        return StatusColors.GREEN
    }
    
    func setImage (status:String) -> String {
        if(status == STATUS.NOT_FINISHED){
            return StatusIcons.YELLOW
        }
        if(status == STATUS.OVERDUE){
            return StatusIcons.RED
        }
        if(status == STATUS.PLANNED){
            return StatusIcons.GREEN
        }
        if(status == STATUS.STARTED){
            return StatusIcons.YELLOW
        }
        if(status == STATUS.NOT_SYNCED) {
            return StatusIcons.RED
        }
        return StatusIcons.GREEN
    }
    
    func openFilter() -> Void {
        performSegue(withIdentifier: "openFilter", sender: nil)
    }
    
    func doLogout() -> Void {
        self.showLogoutAlert()
    }
    
    // MARK: Change date format
    func changeDateFormat(date :Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.M.yyyy"
        return dateFormatter.string(from: date)
    }
    
    func changeDateFormatForPlanned(date :Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.M.yyyy"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        return dateFormatter.string(from: date)
    }
    
    // MARK: Get audit lists
    func getUsers(){
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")

        usersList.removeAll()
        workstation.removeAll()
        planned.removeAll()
        status.removeAll()
        statusText.removeAll()
        auditUserID.removeAll()
        auditIDarray.removeAll()
        auditStartedUserID.removeAll()
        usersStartedList.removeAll()
        
        do {
            if let count:Int? = try db.scalar(Audit_DB.TABLE.count) {
                if(count == 0) {
                    TableViewHelper.EmptyMessage(message: Translator.getLangValue(key: "no_planned_audits"), tableView: self.tableView)
                }
            }
        }catch{
            TableViewHelper.EmptyMessage(message: Translator.getLangValue(key: "no_planned_audits"), tableView: self.tableView)
        }
        
        do {
            for audits in try db.prepare(Audit_DB.TABLE.order(Audit_DB.Planned.desc)) {
                usersList.append(audits[Audit_DB.UserID])
                usersStartedList.append(audits[Audit_DB.Started_UserID])
                workstation.append(audits[Audit_DB.MachineID])

                var plannedTime = NSDate(timeIntervalSince1970:  TimeInterval(audits[Audit_DB.Planned])! / 1000)
                
                var calendar = NSCalendar.current
                calendar.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
                let correctDate = calendar.startOfDay(for: plannedTime as Date)
                let datestart:Date
                if((TimeZone.current.abbreviation()?.range(of: "-")) != nil) {
                    datestart = Date().startOfDay
                }else{
                    datestart = Date().endOfDay!
                }
                
                let thisDate = calendar.startOfDay(for: datestart)
                plannedTime = correctDate as NSDate
                
                let convertedDate = changeDateFormatForPlanned(date: plannedTime as Date)
//                let convertedDate = changeDateFormat(date: plannedTime as Date)
                
                planned.append(convertedDate)
                auditIDarray.append(audits[Audit_DB.IDLPAAudit])
                auditUserID.append(audits[Audit_DB.IDUser])
                auditStartedUserID.append(audits[Audit_DB.Started_IDUser])

                if(audits[Audit_DB.Syncing] == true){
                    status.append(STATUS.NOT_SYNCED)
                    statusText.append(Translator.notSynced())
                }else{
                    // started
                    if(audits[Audit_DB.Started] != "null") {
                        if (plannedTime as Date >= thisDate){
                            status.append(STATUS.STARTED)
                            statusText.append(Translator.started())
                        }else{
                            status.append(STATUS.NOT_FINISHED)
                            statusText.append(Translator.notFinished())
                        }
                        //not started
                    }else{
                        if (plannedTime as Date >= thisDate){
                            status.append(STATUS.PLANNED)
                            statusText.append(Translator.planned())
                        }else{
                            status.append(STATUS.OVERDUE)
                            statusText.append(Translator.overdue())
                        }
                    }
                }
            }
        }catch{

        }
    }
    
    func getAudits() {

        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        let login = Table("login")
        let audit = Table("audit")
        
        let count: Int!
        do {
            count = try db.scalar(audit.count)
        }catch {
            count = 0
        }
        
        if(count > 0){
            try! db.run(audit.drop(ifExists: true))
        }
        
        let IDSession = Expression<String>("IDSession")
        let IDModule = Expression<String>("IDModule")
        let IDLge = Expression<Int>("IDLge")
        let IDUser = Expression<String>("IDUser")
        let datestart:Date
        if((TimeZone.current.abbreviation()?.range(of: "-")) != nil) {
            datestart = Date().startOfDay
        }else{
            datestart = Date().endOfDay!
        }

        var calendar = NSCalendar.current
        calendar.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
        let correctDate = calendar.startOfDay(for: datestart)
        print(NSDate())
        print(correctDate)
        let DateFrom = Int64(correctDate.timeIntervalSince1970 * 1000.0)
        
        var addDaysComponent = DateComponents()
        addDaysComponent.day = 7
        let addDay = Calendar.current.date(byAdding: addDaysComponent, to: datestart)
        let DateTo = Int64((addDay?.timeIntervalSince1970)! * 1000.0)
        
        if let logins = try! db.pluck(login) {
            WS.AUDIT_SERVICE.getAuditsList(Session: logins[IDSession], Module: logins[IDModule], Lge: logins[IDLge], User: logins[IDUser], UserAuditor: logins[IDUser], Machine: "", DateFrom: String(DateFrom), DateTo: String(DateTo))
        }

    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        if(Translator.checkIfKeyExist(key: "firstLogin")){
            self.showActivityIndicatory(uiView: self.view)
            self.getAudits()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.addBackground()
                self.getUsers()
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                self.tableView.reloadData()
                Config.DEFAULTS.removeObject(forKey: "firstLogin")
                self.stopActivityIndicatory()
            }
        }else{
            self.addBackground()
            self.getUsers()
            self.tableView.reloadData()
        }
    
        self.setImageSize()
        self.addNavigationButtons()
    }
    
    // MARK: - Change tableView background
    func addBackground() {
        // Add a background view to the table view
        let messageLabel = UILabel(frame: CGRect(x: 0,y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        messageLabel.textColor = UIColor.white
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        messageLabel.backgroundColor = UIColor(patternImage: UIImage(named: "sciil pattern")!)
        self.tableView.backgroundView = messageLabel
    }
    
    // MARK: - Get from WS image size
    func setImageSize() {
        WS.LOGIN_SERVICE.getImageSize() { (value) in
            Config.DEFAULTS.set(value, forKey: "imageSize")
        }
    }
    
    // MARK: - Add custom buttons to navigation bar
    func addNavigationButtons() {
        // filter button
        let infoButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "info_64px"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(openDocumentation))
        
        let dashBoardButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "dashboard_64px"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(openDashboard))
        
        let filter = UIBarButtonItem(image: UIImage(named: "Filter_64px"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(openFilter))
        
        let logoutButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "logout"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(doLogout))
        
        connection = UIBarButtonItem(image: UIImage(named: "Online_64px"), style: UIBarButtonItemStyle.plain, target: self, action: nil)
        
        filter.tintColor = UIColor.white
        navigationItem.rightBarButtonItems = [logoutButton, infoButton, dashBoardButton ,filter, connection]
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        // Do any additional setup after loading the view.
        self.navigationItem.setHidesBackButton(true, animated: false)
        _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(AuditViewController.internetCheck), userInfo: nil, repeats: true)
    }
    
    func internetCheck() {
        if (Reachability.isConnectedToNetwork() == true) {
            self.connection.image = UIImage(named: "Online_64px")
        }else{
            self.connection.image = UIImage(named: "Offline_64px")
        }
    }
    
    // MARK: - Prepare seque for open Audit
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "openAudit") {
            let viewController = segue.destination as! ManagePageViewController
            viewController.auditID = auditID
        }
        if(segue.identifier == "openFilter"){
            let backItem = UIBarButtonItem()
            backItem.title = Translator.getLangValue(key: "back")
            navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        }

    }
    // MARK: - Activity Indicator
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
}

