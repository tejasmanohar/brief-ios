import UIKit

class addExperienceTableViewController: UITableViewController {
    @IBOutlet weak var headlineTextField: UITextField!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var currentSwitch: UISwitch!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var endDateLabelPlaceholder: UILabel!
    @IBOutlet weak var deleteExperienceButton: UIButton!
    
    var isEdit = false
    var editNum = 100
    var timer : NSTimer = NSTimer()
    var currentWork = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Edit Experience"
        
        deleteExperienceButton.hidden = true
        
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        nav?.titleTextAttributes = [NSFontAttributeName: UIFont(name: "avenirnext-demibold", size: 22)!]
        
        var saveButton : UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "saveDataAndGoBack")
        self.navigationItem.rightBarButtonItem = saveButton
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        self.datePicker.hidden = true
        self.endDatePicker.hidden = true
        
        //Set the current time on labels and make them invisible
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM YYYY"
        var dateStr = dateFormatter.stringFromDate(NSDate())
        self.startDateLabel.text = dateStr
        self.endDateLabel.text = dateStr
        self.startDateLabel.hidden = true
        self.endDateLabel.hidden = true
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("checkSaveButton"), userInfo: nil, repeats: true)
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        checkAndFillInfo()
    }
    
    func checkAndFillInfo() {        
        let editCellNumber = NSUserDefaults.standardUserDefaults().integerForKey("editExperience")
        if editCellNumber != 100 {
            
            isEdit = true
            editNum = editCellNumber
            
            deleteExperienceButton.hidden = false
            
            var editArray = NSUserDefaults.standardUserDefaults().arrayForKey("experience")!
            var editDict: AnyObject = editArray[editCellNumber]
            
            var currentString = "no"
            currentWork = false
            currentSwitch.on = false
            
            if editDict.objectForKey("endDate") == nil {
                currentString = "yes"
                
                currentWork = true
                currentSwitch.on = true
            }
            
            var position = editDict.objectForKey("position") as! String
            
            self.headlineTextField.text = position
            
            var company = editDict.objectForKey("company") as! String
            
            self.companyNameTextField.text = company
            
            //Set the current time on labels and make them invisible
            var startNum = editDict.objectForKey("startDate") as! NSTimeInterval
            if startNum > 10000000000 {
                startNum = startNum/1000
            }
            var startDate = NSDate(timeIntervalSince1970: startNum)
            
            var dateFormatter = NSDateFormatter()
//            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.dateFormat = "MMM YYYY"
            var start = dateFormatter.stringFromDate(startDate)
            self.startDateLabel.text = start
            self.startDateLabel.hidden = false
            self.datePicker.date = startDate
            //
            if editDict.objectForKey("endDate") != "" {
                var endNum = editDict.objectForKey("endDate") as! NSTimeInterval
                if endNum > 10000000000 {
                    endNum = endNum/1000
                }
                var endDate = NSDate(timeIntervalSince1970: endNum)
                var end = dateFormatter.stringFromDate(endDate)
                
                self.endDateLabel.text = end
                self.endDateLabel.hidden = false
                self.endDatePicker.date = endDate
            }
            else {
                currentWork = true
                currentSwitch.on = true
            }
            
            tableView.reloadData()
        }
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 5 {
            if currentWork == false {
                return self.tableView.frame.size.height - 44*5 - 64 - 30
            }
            else {
                return self.tableView.frame.size.height - 44*4 - 64 - 30
            }
        }
        else if indexPath.row == 4 {
            if currentWork == false {
                return 44
            }
            else {
                self.endDateLabel.hidden = true
                self.endDateLabelPlaceholder.hidden = true
                self.endDateLabel.text = ""
                self.endDatePicker.hidden = true
                
                
                return 0
            }
        }
        else {
            return 44
        }
    }
    
    @IBAction func startButtonPressed(sender: UIButton) {
        view.endEditing(true)
        
        self.startDateLabel.hidden = false
        
        self.endDatePicker.hidden = true
        
        if self.datePicker.hidden == true {
            self.datePicker.hidden = false
        }
        else {
            self.datePicker.hidden = true
        }
    }
    
    @IBAction func endButtonPressed(sender: UIButton) {
        view.endEditing(true)
        
        self.endDateLabel.hidden = false
        if self.endDateLabel.text == "" {
            var dateFormatter = NSDateFormatter()
//            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.dateFormat = "MMM YYYY"
            var dateStr = dateFormatter.stringFromDate(NSDate())
            self.endDateLabel.text = dateStr
        }
        
        self.datePicker.hidden = true
        
        if self.endDatePicker.hidden == true {
            self.endDatePicker.hidden = false
        }
        else {
            self.endDatePicker.hidden = true
        }
    }
    
    @IBAction func currentSwitch(sender: UISwitch) {
        if currentSwitch.on {
            currentWork = true
        }
        else {
            currentWork = false
            
            self.endDateLabel.hidden = false
            self.endDateLabelPlaceholder.hidden = false
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func startDatePicked(sender: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
//        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.dateFormat = "MMM YYYY"
        var dateStr = dateFormatter.stringFromDate(datePicker.date)
        self.startDateLabel.text = dateStr
        
        println(datePicker.date.timeIntervalSince1970)
    }
    
    @IBAction func endDatePicked(sender: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
//        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.dateFormat = "MMM YYYY"
        var dateStr = dateFormatter.stringFromDate(endDatePicker.date)
        self.endDateLabel.text = dateStr
        
        println(datePicker.date.timeIntervalSince1970)
    }
    
    func checkSaveButton() {
        var isHeadline = false
        if self.headlineTextField.text != "" {
            isHeadline = true
        }
        var isCompanyName = false
        if self.companyNameTextField.text != "" {
            isCompanyName = true
        }
        var isStart = false
        if self.startDateLabel.hidden == false && self.startDateLabel.text != "" {
            isStart = true
        }
        var isEnd = false
        var isCorrect = true
        
        if currentWork == true {
            isEnd = true
        }
        else {
            if self.endDateLabel.hidden == false && self.endDateLabel.text != "" {
                isEnd = true
                if endDatePicker.date.timeIntervalSince1970 <= datePicker.date.timeIntervalSince1970 {
                    isCorrect = false
                }
            }
        }
        
        if (isHeadline && isCompanyName && isStart && isEnd && isCorrect) {
            println("We can enable the 'Save' button")
            
            self.navigationItem.rightBarButtonItem?.enabled = true
            
        }
        else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    
    func saveDataAndGoBack() {
        timer.invalidate()
        
        if currentWork == true {
            var keychainObjects = NSArray(objects:self.headlineTextField.text, self.companyNameTextField.text, self.datePicker.date.timeIntervalSince1970, 1000)
            var keychainValues = NSArray(objects:"position","company", "startDate","endDate")
            let keychainQuery = NSDictionary(objects: keychainObjects as [AnyObject], forKeys: keychainValues as [AnyObject])
            
            ////Add experience into NSUserDefaults
            var loadArray = NSUserDefaults.standardUserDefaults().arrayForKey("experience")!
            
            if isEdit {
                loadArray[editNum] = keychainQuery
            }
            else {
                loadArray.append(keychainQuery)
            }
            
            NSUserDefaults.standardUserDefaults().setObject(loadArray, forKey: "experience")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        else {
            var keychainObjects = NSArray(objects:self.headlineTextField.text, self.companyNameTextField.text, self.datePicker.date.timeIntervalSince1970, self.endDatePicker.date.timeIntervalSince1970)
            var keychainValues = NSArray(objects:"position","company", "startDate","endDate")
            let keychainQuery = NSDictionary(objects: keychainObjects as [AnyObject], forKeys: keychainValues as [AnyObject])
            
            ////Add experience into NSUserDefaults
            var loadArray = NSUserDefaults.standardUserDefaults().arrayForKey("experience")!
            
            if isEdit {
                loadArray[editNum] = keychainQuery
            }
            else {
                loadArray.append(keychainQuery)
            }
            
            NSUserDefaults.standardUserDefaults().setObject(loadArray, forKey: "experience")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func deleteExperienceButtonPressed(sender: UIButton) {
        ////Add experience into NSUserDefaults
        var loadArray = NSUserDefaults.standardUserDefaults().arrayForKey("experience")!
        
        loadArray.removeAtIndex(editNum)
        
        NSUserDefaults.standardUserDefaults().setObject(loadArray, forKey: "experience")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        timer.invalidate()
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        timer.invalidate()
    }
}
