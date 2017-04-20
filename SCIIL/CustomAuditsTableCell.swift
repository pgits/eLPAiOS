import UIKit

class CustomAuditsTableCell: UITableViewCell {
    // outlets
    @IBOutlet var userText: UILabel!
    @IBOutlet var workstationText: UILabel!
    @IBOutlet var plannedDate: UILabel!
    @IBOutlet var statusImage: UIImageView!
    @IBOutlet var plannedText: UILabel!
    @IBOutlet var statusText: UILabel!
    @IBOutlet var workstationLabel: UILabel!
    @IBOutlet var userLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userLabel.text = Translator.getLangValue(key: "user_audit_list_item")
        workstationLabel.text = Translator.getLangValue(key: "workstation_audit_list_item")
        plannedText.text = Translator.getLangValue(key: "planned_audit_list_item")
        userLabel.sizeToFit()
        workstationLabel.sizeToFit()
        plannedText.sizeToFit()
        statusText.numberOfLines = 2
//        statusText.sizeToFit()
        let userLabelnewString:String = userLabel.text!
        let newX = userText.frame.origin.x + CGFloat(userLabelnewString.characters.count*3)
        userText.frame = CGRect(x: newX, y:userText.frame.origin.y, width: userText.frame.size.width, height: userText.frame.size.height)
        
        let plannedTextnewString:String = plannedText.text!
        let newXplannedText = plannedDate.frame.origin.x + CGFloat(plannedTextnewString.characters.count)
        plannedDate.frame = CGRect(x: newXplannedText, y:plannedDate.frame.origin.y, width: plannedDate.frame.size.width, height: plannedDate.frame.size.height)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
