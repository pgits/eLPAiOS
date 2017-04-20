import UIKit

protocol ModalDelegate {
    func updateImage(data: UIImage)
    func updateImageData(data: Bool)
}

class ModalViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var image: UIImageView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var toolbar: UIToolbar!
    
    var imageFromController: UIImage!
    var isModalAnswerPhoto: Bool!
    var imageWasChanged: Bool!
    var delegate: ModalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageWasChanged = false
        view.isOpaque = false
        image.image = imageFromController
        // Do any additional setup after loading the view.
        closeButton.setFAText(prefixText: "", icon: FAType.FATimesCircle, postfixText: "", size: 80, forState: .normal, iconSize: 30)
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        closeButton.setFATitleColor(color: UIColor.white, forState: .normal)
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "delete_sign_64px_2"), for: .normal)
        button.setTitle(Translator.getLangValue(key: "delete"), for: .normal)
        button.sizeToFit()
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
        
        let button2 = UIButton(type: .system)
        button2.setImage(UIImage(named: "camera_64px_1"), for: .normal)
        button2.setTitle(Translator.getLangValue(key: "change"), for: .normal)
        button2.sizeToFit()
        button2.tintColor = UIColor.white
        button2.addTarget(self, action: #selector(changeImage), for: .touchUpInside)
        
        let leftBarButton = UIBarButtonItem(customView: button)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let rightBarButton = UIBarButtonItem(customView: button2)
        toolbar.setItems([leftBarButton, flexSpace, rightBarButton], animated: true)
        if(!isModalAnswerPhoto){
            toolbar.removeFromSuperview()
        }
    }
    
    func deleteImage(){
        if(image.image != nil) {
            // create the alert
            let alert = UIAlertController(title: Translator.getLangValue(key: "photo_delete_confirmation"), message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "yes"), style: UIAlertActionStyle.default, handler: removeImageHandler))
            
            alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "no"), style: UIAlertActionStyle.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func removeImageHandler(alert: UIAlertAction!) {
        image.image = nil
        self.closeButtonPressed(alert)
    }
    
    func changeImage(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        
        if(isModalAnswerPhoto == true) {
            if let imageData = image.image {
                if(self.imageWasChanged == true){
                    self.delegate?.updateImage(data: imageData)
                }
            }else{
                self.delegate?.updateImageData(data: true)
            }
        }
        dismiss(animated: true, completion: nil)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.image
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image.contentMode = .scaleToFill
            image.image = pickedImage
            self.imageWasChanged = true
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        // only for test
        if(self.isModalAnswerPhoto == true) {
            if let imageData = image.image {
                if(self.imageWasChanged == true){
                    self.delegate?.updateImage(data: imageData)
                }
            }else{
                self.delegate?.updateImageData(data: true)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }

}
