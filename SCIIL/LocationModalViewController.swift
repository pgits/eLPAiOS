import UIKit

class LocationModalViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var closeButton: UIButton!
    @IBOutlet var locationImage: UIImageView!
    @IBOutlet var imageScroll: UIScrollView!
    
    var imageFromController: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false

        locationImage.image = imageFromController
    
        if(imageFromController == nil) {
            let messageLabel = UILabel(frame: CGRect(x: self.view.center.x/1.5,y: self.view.center.y, width: view.bounds.size.width, height: view.bounds.size.height))
            messageLabel.text = Translator.getLangValue(key: "photo_is_not_available")
            messageLabel.textColor = UIColor.white
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
            messageLabel.sizeToFit()

            self.view.addSubview(messageLabel)
        }
        
        self.imageScroll.delegate = self
        self.imageScroll.minimumZoomScale = 1.0
        self.imageScroll.maximumZoomScale = 6.0
        // Do any additional setup after loading the view.
        
        closeButton.setFAText(prefixText: "", icon: FAType.FATimesCircle, postfixText: "", size: 80, forState: .normal, iconSize: 30)
        closeButton.setFATitleColor(color: UIColor.white, forState: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.locationImage
    }

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
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
