import UIKit
import SwiftyJSON
import SQLite

class QuestionsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIScrollViewDelegate {
    var photoIndex :Int!
    var questPhotoName :String!
    var questImg :String!
    var questChap :String!
    var answerText :String!
    var answerImg :String!
    var questID :String!
    var answImgID :String!
    var imageCache = NSCache<NSString, UIImage>()
    var selectedPhotoCache = NSCache<NSString, UIImage>()
    var answers = [String: Answer]()
    var isModalAnswerPhoto: Bool!
    var imageTaken:Bool!
    var textExpanded:Bool = false
    
    @IBOutlet var questionPhoto: UIImageView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var answerPhoto: UIImageView!
    @IBOutlet var questionText: UILabel!
    @IBOutlet var chapterText: UILabel!
    @IBOutlet var blankQuestImg: UIImageView!
    @IBOutlet var blankAnswerImg: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    let fixedButton = UIButton()
    let notOkButton = UIButton()
    let okButton = UIButton()
    
    let arrowButton = UIButton(type: .system)
    
    var fixedButtonPressed = false
    var buttonOkPressed = false
    var buttonNokPressed = false
    
    let NOTOKBUTTON_TAG = 4
    let OKBUTTON_TAG = 5
    let FIXEDBUTTON_TAG = 6

    var selectedImage:UIImage!
    let imagePicker = UIImagePickerController()
    
    // Placeholder text
    var placeholder: String? {
        
        get {
            // Get the placeholder text from the label
            var placeholderText: String?
            
            if let placeHolderLabel = textView.viewWithTag(100) as? UILabel {
                placeholderText = placeHolderLabel.text
            }
            return placeholderText
        }
        
        set {
            // Store the placeholder text in the label
            let placeHolderLabel = textView.viewWithTag(100) as! UILabel?
            if placeHolderLabel == nil {
                // Add placeholder label to text view
                self.addPlaceholderLabel(placeholderText: newValue!)
            }
            else {
                placeHolderLabel?.text = newValue
                placeHolderLabel?.sizeToFit()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.setQuestionText(text: questPhotoName)
        self.setChapterText(text: questChap)
        self.setAnswerText(text: (answers[questID]?.Info1)!)
        questionText.lineBreakMode = .byTruncatingTail
        self.loadAnswerPhoto()
        self.loadQuestionPhoto()
        self.loadButtons()
        self.closeKeyboardOnTaping()
        self.makePhotoOpen()
        
        textView.delegate = self
        textView.layer.borderColor = UIColor.white.cgColor
        textView.layer.borderWidth = 1.0
        textView.tintColor = UIColor.white
        
        self.placeholder = Translator.getLangValue(key: "question_edit_text_hint")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        addArrowButton()
        self.textExpanded = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func addArrowButton() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(QuestionsViewController.expandQuestionText))
//        questionText.isUserInteractionEnabled = true
//        questionText.addGestureRecognizer(tap)
//    }
    
    func addArrowButton() {
        if(questionText.isTruncated()){
            arrowButton.frame = CGRect(x: self.arrowButtonX(), y: self.arrowButtonY(), width: 46, height: 30)
            arrowButton.setImage(UIImage(named: "arrow_down"), for: .normal)
            arrowButton.tintColor = UIColor.white
            arrowButton.addTarget(self, action: #selector(expandQuestionText), for: UIControlEvents.touchUpInside)
            let yPosition = arrowButton.frame.height
            self.scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height + yPosition)
            self.scrollView.addSubview(arrowButton)
        }
    }
    
    func arrowButtonX() -> Int {
        let x:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            x = 136
        case 568: // 5
            x = 140
        case 667: // 6
            x = 165
        case 736: // 6 plus
            x = 184
        default: // 6
            x = 165
        }
        return x
    }
    
    func arrowButtonY() -> Int {
        let y:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            y = 60
        case 568: // 5
            y = 60
        case 667: // 6
            y = 55
        case 736: // 6 plus
            y = 55
        default: // 6
            y = 55
        }
        return y
    }
    
    func expandQuestionText() {
        if(self.textExpanded == true) {
            questionText.numberOfLines = 2
            self.textExpanded = false
            questionText.lineBreakMode = .byTruncatingTail
            textClose()
                    self.scrollView.setNeedsDisplay()
            questionText.frame = CGRect(x: questionText.frame.origin.x, y: questionText.frame.origin.y, width: questionText.frame.width, height: 27)
            arrowButton.setImage(UIImage(named: "arrow_down"), for: .normal)
        }else{
            questionText.numberOfLines = 0
            questionText.sizeToFit()
            self.textExpanded = true
            arrowButton.setImage(UIImage(named: "arrow_up"), for: .normal)
            textExpand()
                    self.scrollView.setNeedsDisplay()
        }
    }
    
    func textExpand() {
        let size = questionText.frame.height - 37
        questionPhoto.frame = CGRect(x: questionPhoto.frame.origin.x, y: questionPhoto.frame.origin.y + size, width: questionPhoto.frame.width, height: questionPhoto.frame.height)
        
        textView.frame = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y + size, width: textView.frame.width, height: textView.frame.height)
        
        answerPhoto.frame = CGRect(x: answerPhoto.frame.origin.x, y: answerPhoto.frame.origin.y + size, width: answerPhoto.frame.width, height: answerPhoto.frame.height)
        
        blankQuestImg.frame = CGRect(x: blankQuestImg.frame.origin.x, y: blankQuestImg.frame.origin.y + size, width: blankQuestImg.frame.width, height: blankQuestImg.frame.height)
        
        blankAnswerImg.frame = CGRect(x: blankAnswerImg.frame.origin.x, y: blankAnswerImg.frame.origin.y  + size, width: blankAnswerImg.frame.width, height: blankAnswerImg.frame.height)
        
        fixedButton.frame = CGRect(x: fixedButton.frame.origin.x, y: fixedButton.frame.origin.y  + size, width: fixedButton.frame.width, height: fixedButton.frame.height)
        
        notOkButton.frame = CGRect(x: notOkButton.frame.origin.x, y: notOkButton.frame.origin.y  + size, width: notOkButton.frame.width, height: notOkButton.frame.height)
        
        okButton.frame = CGRect(x: okButton.frame.origin.x, y: okButton.frame.origin.y  + size, width: okButton.frame.width, height: okButton.frame.height)
        
        arrowButton.frame = CGRect(x: arrowButton.frame.origin.x, y: arrowButton.frame.origin.y  + size, width: arrowButton.frame.width, height: arrowButton.frame.height)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = size
        self.scrollView.contentInset = contentInset
        
    }
    
    func textClose() {
        let size = questionText.frame.height - 37
        questionPhoto.frame = CGRect(x: questionPhoto.frame.origin.x, y: questionPhoto.frame.origin.y - size, width: questionPhoto.frame.width, height: questionPhoto.frame.height)
        
        textView.frame = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y - size, width: textView.frame.width, height: textView.frame.height)
        
        answerPhoto.frame = CGRect(x: answerPhoto.frame.origin.x, y: answerPhoto.frame.origin.y - size, width: answerPhoto.frame.width, height: answerPhoto.frame.height)
        
        blankQuestImg.frame = CGRect(x: blankQuestImg.frame.origin.x, y: blankQuestImg.frame.origin.y - size, width: blankQuestImg.frame.width, height: blankQuestImg.frame.height)
        
        blankAnswerImg.frame = CGRect(x: blankAnswerImg.frame.origin.x, y: blankAnswerImg.frame.origin.y  - size, width: blankAnswerImg.frame.width, height: blankAnswerImg.frame.height)
        
        fixedButton.frame = CGRect(x: fixedButton.frame.origin.x, y: fixedButton.frame.origin.y  - size, width: fixedButton.frame.width, height: fixedButton.frame.height)
        
        notOkButton.frame = CGRect(x: notOkButton.frame.origin.x, y: notOkButton.frame.origin.y  - size, width: notOkButton.frame.width, height: notOkButton.frame.height)
        
        okButton.frame = CGRect(x: okButton.frame.origin.x, y: okButton.frame.origin.y  - size, width: okButton.frame.width, height: okButton.frame.height)
        
        arrowButton.frame = CGRect(x: arrowButton.frame.origin.x, y: arrowButton.frame.origin.y  - size, width: arrowButton.frame.width, height: arrowButton.frame.height)
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            var contentInset:UIEdgeInsets = self.scrollView.contentInset
            contentInset.bottom = keyboardSize.size.height
            self.scrollView.contentInset = contentInset
            
            let scrollPoint : CGPoint = CGPoint(x: 0, y: keyboardSize.size.height)
            self.scrollView.setContentOffset(scrollPoint, animated: true)
            
//            if self.view.frame.origin.y == 0{
//                self.view.frame.origin.y -= keyboardSize.height
//            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y != 0{
//                self.view.frame.origin.y += keyboardSize.height
//            }
//        }
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidEndEditing(textView: UITextView) {
        self.scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func makePhotoOpen() {
        answerPhoto.isUserInteractionEnabled = true
        questionPhoto.isUserInteractionEnabled = true
        let recognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(QuestionsViewController.answerPhotoPressed))
        let recognizer1: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(QuestionsViewController.questionPhotoPressed))
        answerPhoto.addGestureRecognizer(recognizer)
        questionPhoto.addGestureRecognizer(recognizer1)
    }
    
    func closeKeyboardOnTaping() {
        //close keyboard on taping anywhere
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(QuestionsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func setQuestionText(text: String) {
        self.questionText.text = text
        self.questionText.lineBreakMode = .byWordWrapping
        self.questionText.numberOfLines = 0
    }
    
    func setChapterText(text: String) {
        self.chapterText.text = text
    }
    
    func setAnswerText(text: String!) {
        if let answeredText = text {
            self.textView.text = answeredText
        }
    }
    
    func loadAnswerPhoto() {
        if let userPhoto = selectedPhotoCache.object(forKey: questID as NSString){
            answerPhoto.image = userPhoto
            blankAnswerImg.image = nil
        }else{
            if(ImageHelper.imageExists(fileName: self.answImgID)){
                answerPhoto.image = ImageHelper.getImage(fileName: self.answImgID)
                self.blankAnswerImg.image = nil
            }else{
                let imgName = self.answImgID + "_c"
                if(ImageHelper.imageExists(fileName: imgName)){
                    answerPhoto.image = ImageHelper.getImage(fileName: imgName)
                    self.blankAnswerImg.image = nil
                }else{
                    var answerImageString:String!
                    if(self.answImgID != ""){
                        WS.AUDIT_SERVICE.getImageBase64(imageID: self.answImgID) { (imageValue) in
                            answerImageString = String(describing: imageValue["Data64"]) as String?
                            
                            self.answerPhoto.image = ImageHelper.resizeImage(image: self.convertToImage(base64String: answerImageString))
                            
                            ImageHelper.saveImage(image: self.answerPhoto.image!, fileName: self.answImgID)
                            
                            self.selectedPhotoCache.setObject(self.answerPhoto.image!, forKey: self.questID as NSString)
                            self.blankAnswerImg.image = nil
                        }
                    }
                }
            }
        }
    }
    
    func loadQuestionPhoto() {
        if let cachedImage = imageCache.object(forKey: questImg as NSString) {
            questionPhoto.image = cachedImage
            blankQuestImg.image = nil
        }else{
            if(ImageHelper.imageExists(fileName: self.questImg)){
                questionPhoto.image = ImageHelper.getImage(fileName: self.questImg)
                self.blankQuestImg.image = nil
            }else{
                var questionImageString:String!
                //DispatchQueue.main.asyncAfter(deadline: .now()) {
                    if(self.questImg != ""){
                        WS.AUDIT_SERVICE.getImageBase64(imageID: self.questImg) { (imageValue) in
                            questionImageString = String(describing: imageValue["Data64"]) as String?
                            if(questionImageString != "null") {
                                self.questionPhoto.image = self.convertToImage(base64String: questionImageString)
                                self.imageCache.setObject(self.questionPhoto.image!, forKey: self.questImg as NSString)
                                self.blankQuestImg.image = nil
                                
                                ImageHelper.saveImage(image: self.questionPhoto.image!, fileName: self.questImg)
                            }
                        }
                    }
                //}
            }
        }
    }
    
    func loadButtons() {
        if(answers[questID]?.Ok! == 1){
            self.addButtons()
            self.okButtonPressed(_: nil)
            okButton.setTitleColor(Colors.GREEN, for: .normal)
        }else if(answers[questID]?.NotOk! == 1){
            self.addButtons()
            self.notOkButtonPressed(_: nil)
            if(answers[questID]?.ImmediatelyCorrected! == 1){
                self.buttonFixedPressed(_: nil)
            }
        }else{
            self.addButtons()
        }
    }
    
    func questionPhotoPressed(){
        if(questionPhoto.image != nil) {
            selectedImage = questionPhoto.image
            isModalAnswerPhoto = false
            performSegue(withIdentifier:"modalView", sender: self)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text != "") {
            answers[questID]?.Info1 = textView.text
            updateAnsweredValues()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableSwipe"), object: nil)
        }else{
            if(buttonNokPressed){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableSwipe"), object: nil)
                showToast()
            }
            if(answers[questID]?.Info1 != ""){
                answers[questID]?.Info1 = textView.text
                updateAnsweredValues()
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if(textView.text == "" && buttonNokPressed){
            view.endEditing(true)
        }
        
        let placeHolderLabel = textView.viewWithTag(100)
        
        if !textView.hasText {
            // Get the placeholder label
            placeHolderLabel?.isHidden = false
        }
        else {
            placeHolderLabel?.isHidden = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if (text == "\n") {
//            textView.resignFirstResponder()
//            return false
//        }
        return true
    }
    
    func answerPhotoPressed(){
        isModalAnswerPhoto = true
        if(answerPhoto.image == nil){
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }else{
            selectedImage = answerPhoto.image
            performSegue(withIdentifier:"modalView", sender: self)
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            blankAnswerImg.image = nil
            answerPhoto.contentMode = .scaleToFill
            answerPhoto.image = ImageHelper.resizeImage(image: pickedImage)
            self.selectedPhotoCache.setObject(answerPhoto.image!, forKey: self.questID as NSString)
            self.updateAnsweredValues()
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func addButtons() {
        self.buttonOK()
        self.buttonNOK()
    }
    
    func buttonOK(){
        okButton.setImage(UIImage(named: "ok_64px_7"), for: .normal)
        okButton.setTitle(Translator.getLangValue(key: "ok"), for: .normal)
        okButton.sizeToFit()
        okButton.frame = CGRect(x: -20, y: setYforButtons(), width: 150, height: setHeightforButtons())
        if(self.textExpanded == true){
            let size = questionText.frame.height - 37
            okButton.frame = CGRect(x: okButton.frame.origin.x, y: okButton.frame.origin.y  + size, width: okButton.frame.width, height: okButton.frame.height)
        }
        okButton.tag = OKBUTTON_TAG
        okButton.addTarget(self, action: #selector(okButtonPressed(_:)), for: .touchUpInside)
        self.scrollView.addSubview(okButton)
    }
    
    func buttonNOK() {
        notOkButton.setImage(UIImage(named: "cancel_64px_4"), for: .normal)
        notOkButton.setTitle(Translator.getLangValue(key: "nok"), for: .normal)
        notOkButton.sizeToFit()
        notOkButton.frame = CGRect(x: 70, y: setYforButtons(), width: 150, height: setHeightforButtons())
        if(self.textExpanded == true) {
            let size = questionText.frame.height - 37
            notOkButton.frame = CGRect(x: notOkButton.frame.origin.x, y: notOkButton.frame.origin.y  + size, width: notOkButton.frame.width, height: notOkButton.frame.height)
        }
        notOkButton.tag = NOTOKBUTTON_TAG
        notOkButton.addTarget(self, action: #selector(notOkButtonPressed(_:)), for: .touchUpInside)
        self.scrollView.addSubview(notOkButton)
    }
    
    func buttonFixed() {
        fixedButton.setImage(UIImage(named: "support_64px_3"), for: .normal)
        fixedButton.setTitle(Translator.getLangValue(key: "fixed"), for: .normal)
        fixedButton.sizeToFit()
        fixedButton.frame = CGRect(x: 90, y: setYforButtons(), width: 150, height: setHeightforButtons())
        if(self.textExpanded == true) {
            let size = questionText.frame.height - 37
            fixedButton.frame = CGRect(x: fixedButton.frame.origin.x, y: fixedButton.frame.origin.y  + size, width: fixedButton.frame.width, height: fixedButton.frame.height)
        }
        fixedButton.tag = FIXEDBUTTON_TAG
        fixedButton.addTarget(self, action: #selector(buttonFixedPressed(_:)), for: .touchUpInside)
        self.scrollView.addSubview(fixedButton)
    }
    
    func okButtonPressed(_ sender: AnyObject?) {
        notOkButton.removeFromSuperview()
        if(buttonOkPressed){
            self.buttonNOK()
            buttonOkPressed = false
            if(sender?.tag == OKBUTTON_TAG) {
                answers[questID]?.Ok = 0
                updateAnsweredValues()
                okButton.setTitleColor(UIColor.white, for: .normal)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeTitle"), object: nil)
            }
        }else{
            notOkButton.removeFromSuperview()
            buttonOkPressed = true
            if(sender?.tag == OKBUTTON_TAG) {
                answers[questID]?.Ok = 1
                updateAnsweredValues()
                okButton.setTitleColor(Colors.GREEN, for: .normal)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeTitle"), object: nil)
            }
        }
    }
    
    func notOkButtonPressed(_ sender: AnyObject?) {
        
        if(buttonNokPressed){
            buttonNokPressed = false
            notOkButton.removeFromSuperview()
            fixedButton.removeFromSuperview()
            notOkButton.setTitleColor(UIColor.white, for: .normal)
            self.addButtons()
            if(sender?.tag == NOTOKBUTTON_TAG) {
                answers[questID]?.NotOk = 0
                updateAnsweredValues()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeTitle"), object: nil)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableSwipe"), object: nil)
        }else{
            buttonNokPressed = true
            okButton.removeFromSuperview()
            notOkButton.frame = CGRect(x: -20, y: setYforButtons(), width: 150, height: setHeightforButtons())
            if(self.textExpanded == true) {
                let size = questionText.frame.height - 37
                notOkButton.frame = CGRect(x: notOkButton.frame.origin.x, y: notOkButton.frame.origin.y  + size, width: notOkButton.frame.width, height: notOkButton.frame.height)
            }
            notOkButton.setTitleColor(Colors.RED, for: .normal)
            self.buttonFixed()
            fixedButton.setTitleColor(UIColor.white, for: .normal)
            if(sender?.tag == NOTOKBUTTON_TAG){
                answers[questID]?.NotOk = 1
                updateAnsweredValues()
                if(textView.text == "") {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableSwipe"), object: nil)
                    showToast()
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeTitle"), object: nil)
            }

        }

    }
    
    func buttonFixedPressed(_ sender: AnyObject?) {

        if(fixedButtonPressed){
            fixedButtonPressed = false
            fixedButton.setTitleColor(UIColor.white, for: .normal)
            fixedButton.setImage(UIImage(named: "support_64px_3"), for: .normal)
            if(sender?.tag == FIXEDBUTTON_TAG) {
                answers[questID]?.ImmediatelyCorrected = 0
                updateAnsweredValues()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeTitle"), object: nil)
            }
        }else{
            fixedButtonPressed = true
            fixedButton.setTitleColor(Colors.GREEN, for: .normal)
            fixedButton.setImage(UIImage(named: "Support_64px_active"), for: .normal)
            if(sender?.tag == FIXEDBUTTON_TAG) {
                answers[questID]?.ImmediatelyCorrected = 1
                updateAnsweredValues()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeTitle"), object: nil)
            }
        }
    }
    
//    func convertToImage(base64String :String) -> UIImage{
//        let converted = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)
//        let convertedImage : UIImage = UIImage(data: converted!)!
//        
//        return convertedImage
//    }
    
    func convertToImage(base64String: String) -> UIImage {
        let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)
        
        return UIImage(data: data!)!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "modalView") {
            
            let viewController = segue.destination as! ModalViewController
            viewController.imageFromController = selectedImage
            viewController.isModalAnswerPhoto = isModalAnswerPhoto
            viewController.delegate = self
        }
    }
    
    func answeredTime() -> String {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000.0)
        let date :String = "/Date(\(timestamp))/"
        return date
    }
    
    func updateAnsweredValues () {
        answers[questID]?.Answered = answeredTime()
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        if let loggedUser = try! db.pluck(Login_DB.TABLE) {
            answers[questID]?.IDAnsweredBy = loggedUser[Login_DB.IDUser]
        }
    }
    
    func showToast() {
        self.view.makeToast(Translator.getLangValue(key: "not_all_answers_have_comment"), duration: 3.0, position: .bottom)
    }
    
    func setYforButtons() -> Int {
        let y:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            y = 230
        case 568: // 5
            y = 285
        case 667: // 6
            y = 285
        case 736: // 6 plus
            y = 320
        default: // 6
            y = 285
        }
        return y
    }
    
    func setHeightforButtons() -> Int {
        let y:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            y = 80
        case 568: // 5
            y = 80
        case 667: // 6
            y = 80
        case 736: // 6 plus
            y = 80
        default: // 6
            y = 80
        }
        return y
    }
    
    // Add a placeholder label to the text view
    func addPlaceholderLabel(placeholderText: String) {
        
        // Create the label and set its properties
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin.x = 5.0
        placeholderLabel.frame.origin.y = 5.0
        placeholderLabel.font = textView.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        // Hide the label if there is text in the text view
        placeholderLabel.isHidden = (textView.text.characters.count > 0)
        
        textView.addSubview(placeholderLabel)
    }
}

extension QuestionsViewController: ModalDelegate {
    func updateImage(data: UIImage) {
        self.answerPhoto.image = ImageHelper.resizeImage(image: data)
        self.selectedPhotoCache.setObject(self.answerPhoto.image!, forKey: self.questID as NSString)
        answers[questID]?.IDDoc = ""
    }
    
    func updateImageData(data: Bool) {
        if(data == true){
            self.answerPhoto.image = nil
            self.selectedPhotoCache.removeObject(forKey: self.questID as NSString)
            blankAnswerImg.image = UIImage(named: "camera_64px_1")
            answers[questID]?.IDDoc = ""
        }
    }
}
