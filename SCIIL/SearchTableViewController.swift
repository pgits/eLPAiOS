import UIKit

class SearchTableViewController: UITableViewController, UISearchResultsUpdating {
    var searchController = UISearchController()
    
    var tableData:[String] = []
    
    var filteredData:[String] = []
    
    var modalValue:String!
    var selectedValue:String!
    var newBackButton:UIButton = UIButton(type: UIButtonType.custom) as UIButton
    var searchDelegate: SearchViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(modalValue == "module") {
            self.title = Translator.getLangValue(key: "profile")
        }else{
            self.title = Translator.getLangValue(key: "language")
        }
        
        // Search controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = UISearchBarStyle.prominent
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if searchController.isActive {
            return filteredData.count
        }else {
            return tableData.count
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        if (searchController.searchBar.text?.characters.count)! > 0 {
            // 1
            filteredData.removeAll(keepingCapacity: false)
            // 2
//            let searchPredicate = NSPredicate(format: "SELF CONTAINS %@", searchController.searchBar.text!)
//            // 3
//            let array = (tableData as NSArray).filtered(using: searchPredicate)
//            // 4
//            filteredData = array as! [String]
            
            filteredData = tableData.filter({ (country) -> Bool in
                let countryText: NSString = country as NSString
                
                return (countryText.range(of: searchController.searchBar.text!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
            })
            // 5
            tableView.reloadData()
        }else{
            filteredData.removeAll(keepingCapacity: false)
            filteredData = tableData
            tableView.reloadData()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath as IndexPath)
        
        // Configure the cell...
        if searchController.isActive {
            if(filteredData[indexPath.row] == selectedValue){
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
            cell.textLabel?.text = filteredData[indexPath.row]
        }else {
            if(tableData[indexPath.row] == selectedValue){
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
            cell.textLabel?.text = tableData[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var sendValue:String!
        if searchController.isActive {
            sendValue = filteredData[indexPath.row]
        }else {
            sendValue = tableData[indexPath.row]
        }
        
        if(modalValue == "module") {
            self.searchController.dismiss(animated: true, completion: nil)
            self.searchDelegate?.updateModule(data: sendValue)
            _ = navigationController?.popViewController(animated: true)
        }
        
        if(modalValue == "language") {
            self.searchController.dismiss(animated: true, completion: nil)
            self.searchDelegate?.updateLanguage(data: sendValue)
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchController.dismiss(animated: false, completion: nil)
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
