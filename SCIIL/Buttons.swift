import UIKit
import Foundation

public class Buttons {
    
    class func saveButton(selector: Selector) -> UIButton {
        let newSaveButton:UIButton = UIButton(type: UIButtonType.custom) as UIButton
        newSaveButton.addTarget(SettingsViewController.self, action: selector, for: UIControlEvents.touchUpInside)
        newSaveButton.setTitle(Translator.getLangValue(key: "save"), for: UIControlState.normal)
        newSaveButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        newSaveButton.sizeToFit()
        return newSaveButton
    }
    
}
