import UIKit
import SQLite
import SwiftyJSON

class ManagePageViewController: UIPageViewController {
    var questionsList = [String]()
    var questionsChapter = [String]()
    var questionsImg = [String]()
    var answerText = [String]()
    var answerImg = [String]()
    var questID = [String]()
    var answImgID = [String]()
    var answers = [String: Answer]()
    var oldAnswers = [String: Answer]()
    var imgCache = NSCache<NSString, UIImage>()
    var selectedPhotoCache = NSCache<NSString, UIImage>()
    
    var currentIndex = 0
    var auditID:String!
    var locationID: String!
    var locationImage :UIImage!
    var imageTaken:Bool!
    var enabledSwipe:Bool = true
    var imageView: UIImageView?
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var timer : Timer?
    var pageLabel: UILabel = UILabel()
    var isSyncing:Bool = false
    
    var tapGestureRecognizer:UITapGestureRecognizer!
    var newBackButton:UIButton = UIButton(type: UIButtonType.custom) as UIButton
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(red:0.00, green:0.30, blue:0.45, alpha:1.0)
        dataSource = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
//        let tapTitle = UITapGestureRecognizer(target:self, action: #selector(ManagePageViewController.somethingWasTapped(_:)))
        
        showActivityIndicatory(uiView: view)
        
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        self.tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(ManagePageViewController.somethingWasTapped(_:)))
        self.navigationController?.navigationBar.addGestureRecognizer(self.tapGestureRecognizer)

        if let audit = try! db.pluck(Audit_DB.TABLE.filter(Audit_DB.IDLPAAudit == auditID)) {
            self.isSyncing = audit[Audit_DB.Syncing]
        }
        
        if (Reachability.isConnectedToNetwork() == true && !isSyncing) {
            let count: Int!
            do {
                count = try db.scalar(Question_DB.TABLE.count)
            }catch{
                count = 0
            }
        
            if(count > 0){
                try! db.run(Question_DB.TABLE.drop(ifExists: true))
                try! db.run(Chapter_DB.TABLE.drop(ifExists: true))
                try! db.run(Answer_DB.TABLE.drop(ifExists: true))
                try! db.run(Machine_DB.TABLE.drop(ifExists: true))
            }
            WS.AUDIT_SERVICE.getQuestions(AuditID: auditID) { (isOK, jsonDATA) in
                if(isOK){
                    self.getQuestions(jsonDATA: jsonDATA, db: db)
                }else{
                self.navigationController?.navigationBar.removeGestureRecognizer(self.tapGestureRecognizer)
                    self.showAlertServerError()
                    return
                }
            }
        }
        // loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            db.busyTimeout = 5
            do{
                for questionArray in try db.prepare(Question_DB.TABLE) {
                    self.questionsList.append(questionArray[Question_DB.QuestionDesc])
                    self.questionsImg.append(questionArray[Question_DB.IDDoc])
                    self.questID.append(questionArray[Question_DB.IDQuestion])
                    if let chapter = try! db.pluck(Chapter_DB.TABLE.filter(Chapter_DB.IDChapter == questionArray[Question_DB.IDChapter])) {
                        self.questionsChapter.append(chapter[Chapter_DB.ChapterDesc])
                    }
                    if let answer = try! db.pluck(Answer_DB.TABLE.filter(Answer_DB.QuestionID == questionArray[Question_DB.IDQuestion])) {
                        self.answerText.append(answer[Answer_DB.Info1])
                        self.answImgID.append(answer[Answer_DB.IDDoc])
                        self.answers[questionArray[Question_DB.IDQuestion]] = Answer(Closed: answer[Answer_DB.Closed], IDAnsweredBy: answer[Answer_DB.IDAnsweredBy], Ok: answer[Answer_DB.Ok], IDDoc: answer[Answer_DB.IDDoc], Answered: answer[Answer_DB.Answered], Info1: answer[Answer_DB.Info1], IDLPAAudit: answer[Answer_DB.IDLPAAudit], ImmediatelyCorrected: answer[Answer_DB.ImmediatelyCorrected], NotOk: answer[Answer_DB.NotOk], QuestionID: questionArray[Question_DB.IDQuestion])
                    
                        self.oldAnswers[questionArray[Question_DB.IDQuestion]] = Answer(Closed: answer[Answer_DB.Closed], IDAnsweredBy: answer[Answer_DB.IDAnsweredBy], Ok: answer[Answer_DB.Ok], IDDoc: answer[Answer_DB.IDDoc], Answered: answer[Answer_DB.Answered], Info1: answer[Answer_DB.Info1], IDLPAAudit: answer[Answer_DB.IDLPAAudit], ImmediatelyCorrected: answer[Answer_DB.ImmediatelyCorrected], NotOk: answer[Answer_DB.NotOk], QuestionID: questionArray[Question_DB.IDQuestion])
                    }
                }
            }catch {
                self.navigationController?.navigationBar.removeGestureRecognizer(self.tapGestureRecognizer)
//                _ = self.navigationController?.popViewController(animated: true)
                // create the alert
                self.showAlertNoQuestions()
                return
            }
            
            do {
                if let machines = try db.pluck(Machine_DB.TABLE) {
                    self.locationID = machines[Machine_DB.IDDoc]
                }
            }catch{
                self.locationID = ""
            }
            
            self.changeTitle()
            self.currentIndex = self.findNotAnsweredQuestion()
            self.addCustomPageControl()
            // 1
            if let viewController = self.viewQuestionsController(self.currentIndex ) {
                let viewControllers = [viewController]
                // 2
                self.setViewControllers(viewControllers,
                                   direction: .forward,
                                   animated: false,
                                   completion: nil)
            }
            self.stopActivityIndicatory()
            
            // save button
            let saveButton = UIBarButtonItem(image: UIImage(named: "Save_64px"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(self.saveQuestions))
            // location button
            let barButton = UIBarButtonItem(image: UIImage(named: "marker_64px"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(self.openLocationModal))

            if(self.locationID != ""){
                self.navigationItem.rightBarButtonItems = [saveButton, barButton]
            }else{
                self.navigationItem.rightBarButtonItems = [saveButton]
            }
        }
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if (Reachability.isConnectedToNetwork() == true) {
                var questionImageString:String!
                if let locID = self.locationID {
                    WS.AUDIT_SERVICE.getImageBase64(imageID: locID) { (imageValue) in
                        if(imageValue != JSON.null){
                            questionImageString = String(describing: imageValue["Data64"]) as String?
                            self.locationImage = self.convertToImage(base64String: questionImageString)
                        }
                    }
                }
            }
        }
        
        
        super.viewDidLoad()
        self.removeBackButton()
        self.addSwipeObservers()
        
        // copy answers to oldanswers array to check if something has changed
        oldAnswers = answers
    }
    
    func somethingWasTapped(_ sth: AnyObject){
        if(checkNotFilledAnswer()){
            showToast(message: Translator.getLangValue(key: "not_all_answers_have_comment"))
        }else{
            let notAnsweredIndex = self.findNotAnsweredQuestion()
            self.currentIndex = notAnsweredIndex
            self.pageLabel.text = String(notAnsweredIndex+1)
            if let viewController = self.viewQuestionsController(notAnsweredIndex) {
                let viewControllers = [viewController]
                self.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
            }
        }
    }
    
    func disableSwipe(){
        self.dataSource = nil
        self.enabledSwipe = false
    }
    
    func enableSwipe(){
        self.dataSource = self
        self.enabledSwipe = true
    }
    
    func addSwipeObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(enableSwipe), name:NSNotification.Name(rawValue: "enableSwipe"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(disableSwipe), name:NSNotification.Name(rawValue: "disableSwipe"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeTitle), name:NSNotification.Name(rawValue: "changeTitle"), object: nil)
    }
    
    func showActivityIndicatory(uiView: UIView) {
        self.newBackButton.isEnabled = false
        self.newBackButton.isUserInteractionEnabled = false
        self.newBackButton.alpha = 0.5
        
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
        self.newBackButton.isEnabled = true
        self.newBackButton.isUserInteractionEnabled = true
        self.newBackButton.alpha = 1.0
        actInd.stopAnimating()
        container.removeFromSuperview()
    }
    
    func countAnsweredQuestions() -> Int{
        var countAnswered = 0
        for (_, answer) in answers {
            if((answer.Ok == 0 && answer.NotOk == 1) || (answer.Ok == 1 && answer.NotOk == 0)) {
                countAnswered += 1
            }
        }
        return countAnswered
    }
    
    func checkNotFilledAnswer() -> Bool {
        for (_, answer) in answers {
            if(answer.Info1 == "" && answer.NotOk == 1){
                return true
            }
        }
        return false
    }
    
    func findNotAnsweredQuestion() -> Int{
        let count = 0
        if(questID.count-1 != -1) {
            for i in 0...questID.count-1 {
                for (IDquest, answer) in answers {
                    if(IDquest == questID[i]){
                        if(answer.Ok == 0 && answer.NotOk == 0) {
                            return i
                        }
                    }
                }
            }
        }
        return count
    }
    
    func removeBackButton() {
        navigationController?.setNavigationBarHidden(false, animated:true)
//        let newBackButton:UIButton = UIButton(type: UIButtonType.custom) as UIButton
        newBackButton.addTarget(self, action: #selector(backToAuditList), for: UIControlEvents.touchUpInside)
//        newBackButton.setTitle("< " + Translator.getLangValue(key: "back"), for: UIControlState.normal)
//        newBackButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        newBackButton.setImage(UIImage(named: "Cancel 2_64px"), for: UIControlState.normal)
        newBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: newBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
    }
    
    func backToAuditList(sender:UIBarButtonItem){
        if(checkChangesInAnswers()) {
            let alert = UIAlertController(title: Translator.getLangValue(key: "save_changes"), message: "", preferredStyle: UIAlertControllerStyle.alert)
        
            alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "save"), style: UIAlertActionStyle.default, handler: saveHandler))
        
            alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "do_not_save"), style: UIAlertActionStyle.default, handler: discardHandler))
        
            alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "cancel"), style: UIAlertActionStyle.default, handler: nil))
        
        
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }else{
            let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
            if let logins = try! db.pluck(Login_DB.TABLE) {
                WS.AUDIT_SERVICE.resetAuditStatus(AuditID: auditID, Module: logins[Login_DB.IDModule], IDLge: logins[Login_DB.IDLge], User: logins[Login_DB.IDUser])
            }
            self.navigationController?.navigationBar.removeGestureRecognizer(self.tapGestureRecognizer)
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func discardHandler(alert: UIAlertAction!) {
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        if let logins = try! db.pluck(Login_DB.TABLE) {
            WS.AUDIT_SERVICE.resetAuditStatus(AuditID: auditID, Module: logins[Login_DB.IDModule], IDLge: logins[Login_DB.IDLge], User: logins[Login_DB.IDUser])
        }
        self.navigationController?.navigationBar.removeGestureRecognizer(self.tapGestureRecognizer)
        _ = navigationController?.popViewController(animated: true)
    }
    
    func saveHandler(alert: UIAlertAction!) {
        if(checkNotFilledAnswer()){
            showToast(message: Translator.getLangValue(key: "not_all_answers_have_comment"))
        }else{
            showActivityIndicatory(uiView: view)
            if (Reachability.isConnectedToNetwork() == true) {
                NotificationHelper.uploadAudit()
                self.navigationController?.navigationBar.removeGestureRecognizer(self.tapGestureRecognizer)
                WS.AUDIT_SERVICE.saveAnswers(answersArray: answers, savePhoto: selectedPhotoCache) { (saved) in
                    if(saved){
                        NotificationHelper.finishedAuditUploading()
                        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
                        self.saveAnswers(db: db)
                        self.stopActivityIndicatory()
                        _ = self.navigationController?.popViewController(animated: true)
                    }else{
                        self.stopActivityIndicatory()
                        self.showAlertOnErrorSaving()
                    }
                }
            }else{
                self.removeNotSavedAnswers()
                self.offlineSave()
                self.stopActivityIndicatory()
                self.view.endEditing(true)
                self.navigationController?.navigationBar.removeGestureRecognizer(self.tapGestureRecognizer)
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func changeTitle() {
        let questionCount = self.questionsList.count
        let answeredCount = self.countAnsweredQuestions()
        self.navigationItem.title = "\(answeredCount)/\(questionCount)"
    }
    
    func openLocationModal() {
        performSegue(withIdentifier:"locationModal", sender: self)
    }
    
    func saveQuestions() {
        if(checkNotFilledAnswer()){
            showToast(message: Translator.getLangValue(key: "not_all_answers_have_comment"))
        }else{
            showActivityIndicatory(uiView: view)
            if (Reachability.isConnectedToNetwork() == true) {
                NotificationHelper.uploadAudit()
                self.navigationController?.navigationBar.removeGestureRecognizer(self.tapGestureRecognizer)
                WS.AUDIT_SERVICE.saveAnswers(answersArray: answers, savePhoto: selectedPhotoCache) { (saved) in
                    if(saved) {
                        self.clearOldAnswers()
                        self.showToast(message: Translator.getLangValue(key: "finished_uploading"))
                        self.stopActivityIndicatory()
                        self.view.endEditing(true)
                        NotificationHelper.finishedAuditUploading()
                        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
                        self.saveAnswers(db: db)
                        _ = self.navigationController?.popViewController(animated: true)
                    }else{
                        self.showAlertOnErrorSaving()
                        self.stopActivityIndicatory()
                    }
                }
            }else{
                self.removeNotSavedAnswers()
                self.offlineSave()
                self.stopActivityIndicatory()
                self.view.endEditing(true)
                _ = self.navigationController?.popViewController(animated: true)
            }
            self.removeAuditFromList(auditID: auditID)
        }
    }
    
    func removeNotSavedAnswers() {
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        do {
            if try db.run(NotSavedAnswers_DB.TABLE.delete()) > 0 {
                print("deleted Logins")
            } else {
                print("Logins not found")
            }
        } catch {
            print("delete failed: \(error)")
        }
    }
    
    func offlineSave() {
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        
        try! db.run(NotSavedAnswers_DB.TABLE.create(ifNotExists: true) { t in
            t.column(NotSavedAnswers_DB.IDChapter)
            t.column(NotSavedAnswers_DB.Answered)
            t.column(NotSavedAnswers_DB.IDAnsweredBy)
            t.column(NotSavedAnswers_DB.IDDoc)
            t.column(NotSavedAnswers_DB.IDLPAAudit)
            t.column(NotSavedAnswers_DB.ImmediatelyCorrected)
            t.column(NotSavedAnswers_DB.NotOk)
            t.column(NotSavedAnswers_DB.Ok)
            t.column(NotSavedAnswers_DB.IDQuestion)
            t.column(NotSavedAnswers_DB.Info1)
        })
        
        for (questID, answer) in answers {
            if let savedPhoto = selectedPhotoCache.object(forKey: questID as NSString) {
                if(answer.IDDoc! == "") {
                    let fileName = "userphoto_\(WS.AUDIT_SERVICE.randomString(length: 6))"
                    let otherFileName = fileName + "_c"
                    ImageHelper.saveImage(image: savedPhoto, fileName: fileName)
                    ImageHelper.saveImage(image: savedPhoto, fileName: otherFileName)
                    answer.IDDoc! = fileName
                }
            }
        }
        
        for (questID, answer) in answers {
            if let question = try! db.pluck(Question_DB.TABLE.filter(Question_DB.IDQuestion == questID)){
                let insert = NotSavedAnswers_DB.TABLE.insert(NotSavedAnswers_DB.IDChapter <- question[Question_DB.IDChapter],
                                                         NotSavedAnswers_DB.Answered <- answer.Answered,
                                                         NotSavedAnswers_DB.IDAnsweredBy <- answer.IDAnsweredBy,
                                                         NotSavedAnswers_DB.IDDoc <- answer.IDDoc,
                                                         NotSavedAnswers_DB.IDLPAAudit <- answer.IDLPAAudit,
                                                         NotSavedAnswers_DB.ImmediatelyCorrected <- answer.ImmediatelyCorrected,
                                                         NotSavedAnswers_DB.NotOk <- answer.NotOk,
                                                         NotSavedAnswers_DB.Ok <- answer.Ok,
                                                         NotSavedAnswers_DB.IDQuestion <- questID,
                                                         NotSavedAnswers_DB.Info1 <- answer.Info1
                )
                _ = try! db.run(insert)
            }
        }
        
        let saveToDB = Audit_DB.TABLE.filter(Audit_DB.IDLPAAudit == auditID)
        _ = try! db.run(saveToDB.update(Audit_DB.Syncing <- true))
        
        self.saveAnswers(db: db)
        
        self.timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(ManagePageViewController.insertOffline), userInfo: nil, repeats: true)
    }
    
    func saveAnswers(db: Connection) {
        for (questID, answer) in answers {
            let answerDB = Answer_DB.TABLE.filter(Answer_DB.QuestionID == questID)
            do {
                if try db.run(answerDB.update(Answer_DB.IDAnsweredBy <- answer.IDAnsweredBy, Answer_DB.Ok <- answer.Ok, Answer_DB.IDDoc <- answer.IDDoc, Answer_DB.Answered <- answer.Answered, Answer_DB.Info1 <- answer.Info1, Answer_DB.ImmediatelyCorrected <- answer.ImmediatelyCorrected, Answer_DB.NotOk <- answer.NotOk)) > 0 {
                }
            } catch {
                print("update failed: \(error)")
            }
        }
        
        if let login = try! db.pluck(Login_DB.TABLE) {
            let saveToDB = Audit_DB.TABLE.filter(Audit_DB.IDLPAAudit == auditID)
            _ = try! db.run(saveToDB.update(Audit_DB.Started_IDUser <- login[Login_DB.IDUser], Audit_DB.Started_UserID <- login[Login_DB.UserID]))
        }
        
    }
    
    func insertOffline() {
        if (Reachability.isConnectedToNetwork() == true) {
            NotificationHelper.uploadAudit()
            WS.AUDIT_SERVICE.saveAnswersOffline() { (saved, IDAudit) in
                if(saved == true) {
                    self.timer?.invalidate()
                    self.timer = nil
                    let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
                    let saveToDB = Audit_DB.TABLE.filter(Audit_DB.IDLPAAudit == IDAudit)
                    _ = try! db.run(saveToDB.update(Audit_DB.Syncing <- false))
                    self.removeOfflineAuditFromList(auditID: IDAudit)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                    NotificationHelper.finishedAuditUploading()
                }
            }
        }
    }
    
    func countOfflineAnsweredQuestions() -> Int{
        var countAnswered = 0

        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        for list in try! db.prepare(NotSavedAnswers_DB.TABLE.select(NotSavedAnswers_DB.Ok, NotSavedAnswers_DB.NotOk)) {
            if((list[NotSavedAnswers_DB.Ok] == 0 && list[NotSavedAnswers_DB.NotOk] == 1) || (list[NotSavedAnswers_DB.Ok] == 1 && list[NotSavedAnswers_DB.NotOk] == 0)) {
                countAnswered += 1
            }
        }
        
        return countAnswered
    }
    
    func removeOfflineAuditFromList(auditID: String) {
        if (Reachability.isConnectedToNetwork() == true) {
            let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
            let count = try! db.scalar(NotSavedAnswers_DB.TABLE.count)
            
            if(count == self.countOfflineAnsweredQuestions()) {
                do {
                    if try db.run(Audit_DB.TABLE.filter(Audit_DB.IDLPAAudit == auditID).delete()) > 0 {
                        print("Audit removed from list")
                    } else {
                        print("Audit not found")
                    }
                } catch {
                    print("Delete failed: \(error)")
                }
            }
        }
    }
    
    func removeAuditFromList(auditID: String) {
        if (Reachability.isConnectedToNetwork() == true) {
            let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
            if(self.questionsList.count == self.countAnsweredQuestions()) {
                do {
                    if try db.run(Audit_DB.TABLE.filter(Audit_DB.IDLPAAudit == auditID).delete()) > 0 {
                        print("Audit removed from list")
                    } else {
                        print("Audit not found")
                    }
                } catch {
                    print("Delete failed: \(error)")
                }
            }
        }
    }
    
    func clearOldAnswers() {
        self.oldAnswers.removeAll()
        for (questID, answer) in answers {
            oldAnswers[questID] = answer
        }
    }
    
    func checkChangesInAnswers() -> Bool{
        for (key, answer) in answers {
            if(!answer.equals(compareTo: oldAnswers[key]!)){
                return true
            }
        }
        return false
    }
    
    func viewQuestionsController(_ index: Int) -> QuestionsViewController? {
        if let storyboard = storyboard,
            let page = storyboard.instantiateViewController(withIdentifier: "ListViewController") as? QuestionsViewController {
            if(questID.count == 0) {
                return nil
            }
            page.questID = questID[index]
            page.questPhotoName = questionsList[index]
            page.questImg = questionsImg[index]
            page.questChap = questionsChapter[index]
            page.answerText = answerText[index]
            page.answImgID = answImgID[index]
            page.imageCache = imgCache
            page.selectedPhotoCache = selectedPhotoCache
            page.photoIndex = index
            page.answers = answers
            page.imageTaken = imageTaken
            return page
        }
        return nil
    }
    
    func unwrapString(wrappedString :String) -> String{
        var unwrappedString = ""
        
        if let temp = String?(wrappedString) {
            unwrappedString = temp
        }
        
        return unwrappedString
    }
    
    func unwrapInt(wrappedInt :Int) -> Int{
        var unwrappedInt = 0
        
        if let temp = Int?(wrappedInt) {
            unwrappedInt = temp
        }
        
        return unwrappedInt
    }
    
    func getQuestions(jsonDATA: JSON, db: Connection) {
        
        let jsonObj = jsonDATA
        
        let count = jsonObj["Result1"]["AuditQuestions"].count
        
        var chapterArray = [Chapter]()
        var answerArray = [Answer]()
        var questionArray = [Question]()
        var machineArray = [Machine]()
        
        let machine = jsonObj["Result1"]["Machine"]
        
        let machineData = Machine(IDDoc: machine["IDDoc"].string!, IDMachine: machine["IDMachine"].string!, MachineDesc: machine["MachineDesc"].string!, MachineID: machine["MachineID"].string!)
        machineArray.append(machineData)
        
        if(count > 0) {
            for i in 0...count-1 {
                if let resultArray = jsonObj["Result1"]["AuditQuestions"][i]["Questions"].array {
                    let chapterData = Chapter(ChapterDesc: jsonObj["Result1"]["AuditQuestions"][i]["Chapter"]["ChapterDesc"].string!, IDChapter: jsonObj["Result1"]["AuditQuestions"][i]["Chapter"]["IDChapter"].string!, ChapterID: jsonObj["Result1"]["AuditQuestions"][i]["Chapter"]["ChapterID"].string!,Info1: jsonObj["Result1"]["AuditQuestions"][i]["Chapter"]["Info1"].string!)
                    chapterArray.append(chapterData)
                    for data in resultArray {
                        // questions
                        let IDQuestion = self.unwrapString(wrappedString: data["Question"]["IDQuestion"].string!)
                        var Chapter = ""
                        if(data["Question"]["Chapter"] != JSON.null){
                            Chapter = self.unwrapString(wrappedString: data["Question"]["Chapter"].string!)
                        }
                        let QuestionDesc = self.unwrapString(wrappedString: data["Question"]["QuestionDesc"].string!)
                        let IDDoc_Q = self.unwrapString(wrappedString: data["Question"]["IDDoc"].string!)
                        let Info1_Q = self.unwrapString(wrappedString: data["Question"]["Info1"].string!)
                        let QuestionID = self.unwrapString(wrappedString: data["Question"]["QuestionID"].string!)
                        let IDParentQuestion = self.unwrapString(wrappedString: data["Question"]["IDParentQuestion"].string!)
                        
                        let questionData = Question(IDQuestion: IDQuestion, Chapter: Chapter, QuestionDesc: QuestionDesc, IDDoc: IDDoc_Q, Info1: Info1_Q, QuestionID: QuestionID, IDParentQuestion: IDParentQuestion, IDChapter: jsonObj["Result1"]["AuditQuestions"][i]["Chapter"]["IDChapter"].string!)
                        questionArray.append(questionData)
                        // questions end
                        
                        // answers
                        let Closed = self.unwrapInt(wrappedInt: data["Answer"]["Closed"].int!)
                        let IDAnsweredBy = self.unwrapString(wrappedString: data["Answer"]["IDAnsweredBy"].string!)
                        let Ok = self.unwrapInt(wrappedInt: data["Answer"]["Ok"].int!)
                        let IDDoc = self.unwrapString(wrappedString: data["Answer"]["IDDoc"].string!)
                        
                        var Answered = ""
                        if(data["Answer"]["Answered"] != JSON.null){
                            Answered = self.unwrapString(wrappedString: data["Answer"]["Answered"].string!)
                        }
                        let Info1 = self.unwrapString(wrappedString: data["Answer"]["Info1"].string!)
                        let IDLPAAudit = self.unwrapString(wrappedString: data["Answer"]["IDLPAAudit"].string!)
                        let ImmediatelyCorrected = self.unwrapInt(wrappedInt: data["Answer"]["ImmediatelyCorrected"].int!)
                        let NotOk = self.unwrapInt(wrappedInt: data["Answer"]["NotOk"].int!)
                        
                        let answerData = Answer(Closed: Closed, IDAnsweredBy: IDAnsweredBy, Ok: Ok, IDDoc: IDDoc, Answered: Answered, Info1: Info1, IDLPAAudit: IDLPAAudit, ImmediatelyCorrected: ImmediatelyCorrected, NotOk: NotOk, QuestionID: IDQuestion)
                        answerArray.append(answerData)
                        // answers end
                    }
                }
            }
            
            WS.AUDIT_SERVICE.insertChapter(chapterArray: chapterArray, db: db)
            WS.AUDIT_SERVICE.insertAnswer(answerArray: answerArray, db: db)
            WS.AUDIT_SERVICE.insertQuestion(questionArray: questionArray, db: db)
            WS.AUDIT_SERVICE.insertMachine(machineArray: machineArray, db: db)
        }
        

        
    }
    
    func convertToImage(base64String :String) -> UIImage{
        let converted = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)
        let convertedImage : UIImage = UIImage(data: converted!)!
        
        return convertedImage
    }
    
    func showToast(message: String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "locationModal") {
            
            let viewController = segue.destination as! LocationModalViewController
            viewController.imageFromController = locationImage
        }
    }
    
    func addCustomPageControl() {
        self.addPaginationView()
        self.addFirstQuestionButton()
        self.addPreviousQuestionButton()
        self.addNextQuestionButton()
        self.addLastQuestionButton()
        self.addQuestionNumberLabel()
    }
    
    func addPaginationView() {
        let screenSize: CGRect = UIScreen.main.bounds
        let myView = UIView(frame: CGRect(x: 0, y: NavigationHelper.paginationViewY(), width: Int(screenSize.width), height: 65))
        myView.backgroundColor = UIColor(red:0.00, green:0.30, blue:0.45, alpha:1.0)
        self.view.addSubview(myView)
    }
    
    func addFirstQuestionButton() {
        let button = UIButton(type: .system) // let preferred over var here
        button.frame = CGRect(x: NavigationHelper.firstQuestionX(), y: NavigationHelper.firstQuestionY(), width: NavigationHelper.firstQuestionW(), height: NavigationHelper.firstQuestionH())
        button.setImage(UIImage(named: "angle_line_left_32px"), for: UIControlState.normal)
        button.tintColor = UIColor.white
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 27)
        button.addTarget(self, action: #selector(firstQuestionButton), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button)
    }
    
    func addPreviousQuestionButton() {
        let button = UIButton(type: .system) // let preferred over var here
        button.frame = CGRect(x: NavigationHelper.previousQuestionX(), y: NavigationHelper.previousQuestionY(), width: NavigationHelper.previousQuestionW(), height: NavigationHelper.previousQuestionH())
        button.setImage(UIImage(named: "angle_left_32px"), for: UIControlState.normal)
        button.tintColor = UIColor.white
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 27)
        button.addTarget(self, action: #selector(previousQuestionButton), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button)
    }
    
    func addNextQuestionButton() {
        let button = UIButton(type: .system) // let preferred over var here
        button.frame = CGRect(x: NavigationHelper.nextQuestionX(), y: NavigationHelper.nextQuestionY(), width: NavigationHelper.nextQuestionW(), height: NavigationHelper.nextQuestionH())
        button.setImage(UIImage(named: "angle_right_32px"), for: UIControlState.normal)
        button.tintColor = UIColor.white
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 27)
        button.addTarget(self, action: #selector(nextQuestionButton), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button)
    }
    
    func addLastQuestionButton() {
        let button = UIButton(type: .system) // let preferred over var here
        button.frame = CGRect(x: NavigationHelper.lastQuestionX(), y: NavigationHelper.lastQuestionY(), width: NavigationHelper.lastQuestionW(), height: NavigationHelper.lastQuestionH())
        button.setImage(UIImage(named: "angle_line_right_32px"), for: UIControlState.normal)
        button.tintColor = UIColor.white
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 27)
        button.addTarget(self, action: #selector(lastQuestionButton), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button)
    }
    
    func addQuestionNumberLabel() {
        pageLabel.frame = CGRect(x: NavigationHelper.labelX(), y: NavigationHelper.labelY(), width: NavigationHelper.labelW(), height: NavigationHelper.labelH())
        pageLabel.textColor = UIColor.white
        pageLabel.text = String(self.currentIndex+1)
        self.view.addSubview(pageLabel)
    }
    
    func firstQuestionButton() {
        if(self.enabledSwipe == true) {
            if(self.currentIndex != 0) {
                let index = 0
                self.currentIndex = index
                self.pageLabel.text = String(self.currentIndex+1)
                if let viewController = self.viewQuestionsController(index) {
                    let viewControllers = [viewController]
                    // 2
                    self.setViewControllers(viewControllers,
                                            direction: .reverse,
                                            animated: true,
                                            completion: nil)
                }
            }
        }else{
            self.showToast(message: Translator.getLangValue(key: "not_all_answers_have_comment"))
        }
    }
    
    func previousQuestionButton() {
        if(self.enabledSwipe == true) {
            if(self.currentIndex != 0) {
                let index = self.currentIndex - 1
                self.currentIndex = index
                self.pageLabel.text = String(self.currentIndex+1)

                if let viewController = self.viewQuestionsController(index) {
                    let viewControllers = [viewController]
                    // 2
                    self.setViewControllers(viewControllers,
                                            direction: .reverse,
                                            animated: true,
                                            completion: nil)
                }
            }
        }else{
            self.showToast(message: Translator.getLangValue(key: "not_all_answers_have_comment"))
        }
    }
    
    func nextQuestionButton() {
        if(self.enabledSwipe == true) {
            if(self.currentIndex != questionsList.count-1){
                let index = self.currentIndex + 1
                self.currentIndex = index
                self.pageLabel.text = String(self.currentIndex+1)

                if let viewController = self.viewQuestionsController(index) {
                    let viewControllers = [viewController]
                    // 2
                    self.setViewControllers(viewControllers,
                                            direction: .forward,
                                            animated: true,
                                            completion: nil)
                }
            }
        }else{
            self.showToast(message: Translator.getLangValue(key: "not_all_answers_have_comment"))
        }
    }
    
    func lastQuestionButton() {
        if(self.enabledSwipe == true) {
            if(self.currentIndex != questionsList.count-1){
                let index = questionsList.count-1
                self.currentIndex = index
                self.pageLabel.text = String(self.currentIndex+1)
                if let viewController = self.viewQuestionsController(index) {
                    let viewControllers = [viewController]
                    // 2
                    self.setViewControllers(viewControllers,
                                            direction: .forward,
                                            animated: true,
                                            completion: nil)
                }
            }
        }else{
            self.showToast(message: Translator.getLangValue(key: "not_all_answers_have_comment"))
        }
    }
}

//MARK: implementation of UIPageViewControllerDataSource
extension ManagePageViewController: UIPageViewControllerDataSource {
    // 1
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? QuestionsViewController {
            var index = viewController.photoIndex
            imgCache = viewController.imageCache
            guard index != NSNotFound && index != 0 else { self.pageLabel.text = String(1); return nil }
            self.currentIndex = index!
            self.pageLabel.text = String(self.currentIndex+1)
            index = index! - 1
            self.changeTitle()
            return viewQuestionsController(index!)
        }
        return nil
    }
    
    // 2
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? QuestionsViewController {
            var index = viewController.photoIndex
            imgCache = viewController.imageCache
            guard index != NSNotFound else { return nil }
            self.currentIndex = index!
            self.pageLabel.text = String(self.currentIndex+1)
            index = index! + 1
            guard index != questionsList.count else {return nil}
            self.changeTitle()
            return viewQuestionsController(index!)
        }
        return nil
    }
    

}
