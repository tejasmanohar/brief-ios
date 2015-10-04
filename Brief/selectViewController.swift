import UIKit

class selectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var selectedField = 1000
    
    let industries = ["Industry 1", "Industry 2", "Industry 3", "Industry 4", "Industry 5", "Industry 6", "Industry 7", "Industry 8", "Industry 9", "Industry 10"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Select Industry"
        
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        nav?.titleTextAttributes = [NSFontAttributeName: UIFont(name: "avenirnext-demibold", size: 22)!]
        
        var logButton : UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "saveDataAndGoBack")
        self.navigationItem.rightBarButtonItem = logButton
        
        self.navigationItem.rightBarButtonItem?.enabled = false
    }
    
    func saveDataAndGoBack() {
        self.navigationController!.popViewControllerAnimated(true)
        
        NSUserDefaults.standardUserDefaults().setObject(industries[selectedField], forKey: "selectedIndustryName")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return industries.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = industries[row]
        
        if selectedField > industries.count {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        else
        {
            self.navigationItem.rightBarButtonItem?.enabled = true
            
            if selectedField == indexPath.row {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        cell.textLabel?.textColor = UIColor(red: 126.0/255.0, green: 127.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        
        cell.tintColor = UIColor(red: 126.0/255.0, green: 127.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let row = indexPath.row
        selectedField = indexPath.row
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
