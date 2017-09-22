//
//  FilterViewController.swift
//  SCIIL
//
//  Created by Eugenijus Denisov on 09/11/16.
//  Copyright © 2016 Eugenijus Denisov. All rights reserved.
//

import UIKit
import SQLite

class FilterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet var pickerTextField: UITextField!
    @IBOutlet var workstationTextField: UITextField!
    @IBOutlet var dateFromTextField: UITextField!
    @IBOutlet var dateToTextField: UITextField!
    
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var workstationLabel: UILabel!
    @IBOutlet var fromLabel: UILabel!
    @IBOutlet var toLabel: UILabel!
    
    var usersSelect = [String]()
    var workstationSelect = [String]()
    
    let userPickerView = UIPickerView()
    let workstationPickerView = UIPickerView()
    let datePickerTo:UIDatePicker = UIDatePicker()
    let datePickerFrom:UIDatePicker = UIDatePicker()
    
    var dateFromTimeStamp :Int64 = 0
    var dateToTimeStamp :Int64 = 0
    
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var newSaveButton:UIButton = UIButton(type: UIButtonType.custom) as UIButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (Reachability.isConnectedToNetwork() == false) {
            self.showAlertInternetError()
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        datePickerFrom.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        userLabel.text = Translator.getLangValue(key: "user")
        workstationLabel.text = Translator.getLangValue(key: "machine")
        fromLabel.text = Translator.getLangValue(key: "from")
        toLabel.text = Translator.getLangValue(key: "to")
        self.title = Translator.getLangValue(key: "filter")
        
        pickerTextField.tintColor = UIColor.clear // hides caret
        workstationTextField.tintColor = UIColor.clear // hides caret
        dateFromTextField.tintColor = UIColor.clear // hides caret
        dateToTextField.tintColor = UIColor.clear // hides caret
        
        self.userPicker()
        self.workstationPicker()
        
        self.addDefaultDates()
        self.saveButton()
        showActivityIndicatory(uiView: self.view)
        self.newSaveButton.isEnabled = false
        self.newSaveButton.isUserInteractionEnabled = false
        self.newSaveButton.alpha = 0.1
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        if let logins = try! db.pluck(Login_DB.TABLE) {
            WS.AUDITORS_SERVICE.getAuditors(IDSession: logins[Login_DB.IDSession], IDModule: logins[Login_DB.IDModule], LgeID: logins[Login_DB.IDLge], UserIDS: logins[Login_DB.IDUser])
        
            WS.WORKSTATION_SERVICE.getWorkstations(IDSession: logins[Login_DB.IDSession], IDModule: logins[Login_DB.IDModule], LgeID: logins[Login_DB.IDLge], UserIDS: logins[Login_DB.IDUser])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.assignUsersArray()

            if(Translator.checkIfKeyExist(key: "user_filter") == false) {
                let defaultProfileIndex = self.usersSelect.index(of: Config.DEFAULTS.string(forKey: "username")!)
                if(defaultProfileIndex != nil) {
                    self.userPickerView.selectRow(defaultProfileIndex!, inComponent: 0, animated: true)
                    self.pickerTextField.text = self.usersSelect[defaultProfileIndex!]
                }
            }
            self.stopActivityIndicatory()
            self.newSaveButton.isEnabled = true
            self.newSaveButton.isUserInteractionEnabled = true
            self.newSaveButton.alpha = 1.0
        }
        self.setFilterFields()
        
    }
    
    func addDefaultDates() {
        // Do any additional setup after loading the view.
        let datestart:Date
        if((TimeZone.current.abbreviation()?.range(of: "-")) != nil) {
            datestart = Date().startOfDay
        }else{
            datestart = Date().endOfDay!
        }

        dateFromTextField.text = changeDateFormat(date: datestart)
        
        var calendar = NSCalendar.current
        calendar.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
        let correctDate = calendar.startOfDay(for: datestart)
        datePickerFrom.date = correctDate
        print(correctDate)
        let dateFromTimestamp = Int64(correctDate.timeIntervalSince1970 * 1000.0)
        dateFromTimeStamp = dateFromTimestamp
        
        var addDaysComponent = DateComponents()
        addDaysComponent.day = 7
        let addDay = Calendar.current.date(byAdding: addDaysComponent, to: datestart)
        dateToTextField.text = changeDateFormat(date: addDay!)
        datePickerTo.date = addDay!
        let dateToTimestamp = Int64((addDay?.timeIntervalSince1970)! * 1000.0)
        dateToTimeStamp = dateToTimestamp
    }
    
    func userPicker() {
        // userPicker
        let toolBarUser = UIToolbar().ToolbarPiker(mySelect: #selector(dissmisToolBarUser))
        userPickerView.delegate = self
        userPickerView.dataSource = self
        pickerTextField.delegate = self
        pickerTextField.inputView = userPickerView
        pickerTextField.inputAccessoryView = toolBarUser
    }
    
    func workstationPicker() {
        //workstationPicker
        let toolBarWorkstation = UIToolbar().ToolbarPiker(mySelect: #selector(dissmisToolBarWorkstation))
        workstationPickerView.delegate = self
        workstationPickerView.dataSource = self
        workstationTextField.delegate = self
        workstationTextField.inputView = workstationPickerView
        workstationTextField.inputAccessoryView = toolBarWorkstation
    }
    
    func saveButton() {
        newSaveButton.addTarget(self, action: #selector(self.saveButtonPressed), for: UIControlEvents.touchUpInside)
        newSaveButton.setTitle(Translator.getLangValue(key: "save"), for: UIControlState.normal)
        newSaveButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        newSaveButton.sizeToFit()
        let saveButton = UIBarButtonItem(customView: newSaveButton)
        navigationItem.rightBarButtonItems = [saveButton]
        
        //close keyboard on taping anywhere
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FilterViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == userPickerView){
            return usersSelect.count
        }
        if(pickerView == workstationPickerView){
            return workstationSelect.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == userPickerView){
            return usersSelect[row]
        }
        if(pickerView == workstationPickerView){
            return workstationSelect[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickerView == userPickerView){
            if(usersSelect.count > 0){
                pickerTextField.text = usersSelect[row]
            }
        }
        if(pickerView == workstationPickerView){
            if(workstationSelect.count > 0){
                workstationTextField.text = workstationSelect[row]
            }
        }
    }
    
    @IBAction func toDatePicker(_ sender: AnyObject) {
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(dismissToDate))
        datePickerTo.datePickerMode = UIDatePickerMode.date
        dateToTextField.inputView = datePickerTo
        dateToTextField.inputAccessoryView = toolBar
        datePickerTo.addTarget(self, action: #selector(FilterViewController.toDatePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    @IBAction func formDatePicker(_ sender: AnyObject) {
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(dismissFromDate))
        datePickerFrom.datePickerMode = UIDatePickerMode.date
        dateFromTextField.inputView = datePickerFrom
        dateFromTextField.inputAccessoryView = toolBar
        datePickerFrom.addTarget(self, action: #selector(FilterViewController.fromDatePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    func fromDatePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.M.yyyy"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        dateFromTextField.text = dateFormatter.string(from: sender.date)
        
        var calendar = NSCalendar.current
        calendar.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
        let correctDate = calendar.startOfDay(for: sender.date)
//        datePickerFrom.date = correctDate
        let timestamp = Int64(correctDate.timeIntervalSince1970 * 1000.0)
        print(timestamp)
        dateFromTimeStamp = timestamp
    }
    func toDatePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.M.yyyy"
        dateToTextField.text = dateFormatter.string(from: sender.date)
        let timestamp = Int64(sender.date.timeIntervalSince1970 * 1000.0)
        dateToTimeStamp = timestamp
    }
    func changeDateFormat(date :Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.M.yyyy"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone

        return dateFormatter.string(from: date)
    }
    func assignUsersArray(){
        let path = NSSearchPathForDirectoriesInDomains(
                    .documentDirectory, .userDomainMask, true
                    ).first!
        
        let db = try! Connection("\(path)/\(Config.DB_FILE)")
        let auditorsList = Table("auditorsList")
        let workstationList = Table("machinesList")
        
        let UserID = Expression<String>("UserID")
        let MachineID = Expression<String>("MachineID")
        
        for user in try! db.prepare(auditorsList) {
            usersSelect.append(user[UserID])
        }
        
        workstationSelect.append("")
        for machine in try! db.prepare(workstationList) {
            workstationSelect.append(machine[MachineID])
        }
        self.workstationPickerView.reloadAllComponents()
    }
    
    func setFilterFields(){
        let defaults = UserDefaults.standard
        if let user = defaults.string(forKey: "user_filter") {
            pickerTextField.text = user
        }
        if let machine = defaults.string(forKey: "machine_filter"){
            workstationTextField.text = machine
        }
        
        if(Translator.checkIfKeyExist(key: "dateFromTimeStamp")) {
            let savedTimeStamp = Config.DEFAULTS.string(forKey: "dateFromTimeStamp")
            let plannedTime = NSDate(timeIntervalSince1970:  TimeInterval(savedTimeStamp!)! / 1000)
            var calendar = NSCalendar.current
            calendar.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
            let correctDate = calendar.startOfDay(for: plannedTime as Date)

            datePickerFrom.date = correctDate as Date
            dateFromTextField.text = changeDateFormat(date: correctDate)
            dateFromTimeStamp = Int64(savedTimeStamp!)!
        }
        
        if(Translator.checkIfKeyExist(key: "dateToTimeStamp")) {
            let savedTimeStamp = Config.DEFAULTS.string(forKey: "dateToTimeStamp")
            let plannedTime = NSDate(timeIntervalSince1970:  TimeInterval(savedTimeStamp!)! / 1000)
            datePickerTo.date = plannedTime as Date
            dateToTextField.text = changeDateFormat(date: datePickerTo.date)
            dateToTimeStamp = Int64(savedTimeStamp!)!
        }
    }
    
    func saveButtonPressed(){
        let defaults = UserDefaults.standard
        defaults.set(String(dateFromTimeStamp), forKey: "dateFromTimeStamp")
        defaults.set(String(dateToTimeStamp), forKey: "dateToTimeStamp")
        defaults.set(pickerTextField.text, forKey: "user_filter")
        defaults.set(workstationTextField.text, forKey: "machine_filter")
        
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        let db = try! Connection("\(path)/\(Config.DB_FILE)")
        let login = Table("login")
        let auditorsList = Table("auditorsList")
        let machineList = Table("machinesList")
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
        let MachineID = Expression<String>("MachineID")
        let UserID = Expression<String>("UserID")
        let IDMachine = Expression<String>("IDMachine")
        
        if (Reachability.isConnectedToNetwork() == false) {
            self.showAlertInternetError()
        }else{
            self.newSaveButton.isEnabled = false
            self.newSaveButton.isUserInteractionEnabled = false
            self.newSaveButton.alpha = 0.5
            if let logins = try! db.pluck(login) {
                if let list = try! db.pluck(auditorsList.filter(UserID == pickerTextField.text!)){
                    if let machine = try! db.pluck(machineList.filter(MachineID == workstationTextField.text!)) {
                        WS.AUDIT_SERVICE.getAuditsList(Session: logins[IDSession], Module: logins[IDModule], Lge: logins[IDLge], User: logins[IDUser], UserAuditor: list[IDUser], Machine: machine[IDMachine], DateFrom: String(dateFromTimeStamp), DateTo: String(dateToTimeStamp))
                    }else{
                        WS.AUDIT_SERVICE.getAuditsList(Session: logins[IDSession], Module: logins[IDModule], Lge: logins[IDLge], User: logins[IDUser], UserAuditor: list[IDUser], Machine: "", DateFrom: String(dateFromTimeStamp), DateTo: String(dateToTimeStamp))
                    }
                }
            }
            
            view.endEditing(true)
            self.view.makeToast(Translator.getLangValue(key: "filter_saved"), duration: 3.0, position: .bottom)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }

    }
    
    func dissmisToolBarUser() {
        if(usersSelect.count > 0) {
            let row = userPickerView.selectedRow(inComponent: 0)
            pickerTextField.text = usersSelect[row]
            view.endEditing(true)
        }
    }
    
    func dissmisToolBarWorkstation() {
        if(workstationSelect.count > 0) {
            let row = workstationPickerView.selectedRow(inComponent: 0)
            workstationTextField.text = workstationSelect[row]
            view.endEditing(true)
        }
    }
    
    func dismissToDate() {
        toDatePickerValueChanged(sender:datePickerTo)
        view.endEditing(true)
    }
    
    func dismissFromDate() {
        fromDatePickerValueChanged(sender:datePickerFrom)
        view.endEditing(true)
    }
    
    func dismissPicker() {
        view.endEditing(true)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


