import Foundation
import UIKit

class TableViewHelper {
    
    class func EmptyMessage(message:String, tableView:UITableView) {
        let messageLabel = UILabel(frame: CGRect(x: 0,y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.white
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        messageLabel.backgroundColor = UIColor(patternImage: UIImage(named: "sciil pattern")!)
        tableView.backgroundView = messageLabel;
        tableView.separatorStyle = .none;
    }
}
