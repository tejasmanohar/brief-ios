import UIKit

class addEducationTableViewController: UITableViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDateLabelPlaceholder: UILabel!
    @IBOutlet weak var currentSwitch: UISwitch!
    @IBOutlet weak var schoolNameLabel: UITextField!
    @IBOutlet weak var degreeLabel: UITextField!
    @IBOutlet weak var deleteEducationButton: UIButton!
    
    var currentWork = false
    var timer : NSTimer = NSTimer()
    var isEdit = false
    var editNum = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Edit Education"
        
        deleteEducationButton.hidden = true
        
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
        dateFormatter.dateFormat = "YYYY"
        var dateStr = dateFormatter.stringFromDate(NSDate())
        self.startDateLabel.text = dateStr
        self.endDateLabel.text = dateStr
        self.startDateLabel.hidden = true
        self.endDateLabel.hidden = true
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("checkSaveButton"), userInfo: nil, repeats: true)
        
        checkAndFillInfo()
    }
    
    
    func checkAndFillInfo() {
        let editCellNumber = NSUserDefaults.standardUserDefaults().integerForKey("editEducation")
        if editCellNumber != 100 {
            deleteEducationButton.hidden = false
            
            isEdit = true
            editNum = editCellNumber
            
            var editArray = NSUserDefaults.standardUserDefaults().arrayForKey("education")!
            var editDict: AnyObject = editArray[editCellNumber]
            
            var school = editDict.objectForKey("school") as! String
            self.schoolNameLabel.text = school
            
            var degree = editDict.objectForKey("degree") as! String
            self.degreeLabel.text = degree
            
            //Set the current time on labels and make them invisible
            var startNum = editDict.objectForKey("startDate") as! NSTimeInterval
            if startNum > 10000000000 {
                startNum = startNum/1000
            }
            var startDate = NSDate(timeIntervalSince1970: startNum)
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "YYYY"
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
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
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
            dateFormatter.dateFormat = "YYYY"
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

    @IBAction func startDatePicked(sender: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY"
        var dateStr = dateFormatter.stringFromDate(datePicker.date)
        self.startDateLabel.text = dateStr
    }
    
    @IBAction func endDatePicked(sender: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY"
        var dateStr = dateFormatter.stringFromDate(endDatePicker.date)
        self.endDateLabel.text = dateStr
    }
    
    func checkSaveButton() {
        var isSchool = false
        if self.schoolNameLabel.text != "" {
            isSchool = true
        }
        var isDegree = false
        if self.degreeLabel.text != "" {
            isDegree = true
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
        
        if (isSchool && isDegree && isStart && isEnd && isCorrect) {
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
            var keychainObjects = NSArray(objects:self.schoolNameLabel.text, self.degreeLabel.text, self.datePicker.date.timeIntervalSince1970, 1000)
            var keychainValues = NSArray(objects:"school","degree", "startDate", "endDate")
            let keychainQuery = NSDictionary(objects: keychainObjects as [AnyObject], forKeys: keychainValues as [AnyObject])
            
            ////Add experience into NSUserDefaults
            var loadArray = NSUserDefaults.standardUserDefaults().arrayForKey("education")!
            
            if isEdit {
                loadArray[editNum] = keychainQuery
            }
            else {
                loadArray.append(keychainQuery)
            }
            
            NSUserDefaults.standardUserDefaults().setObject(loadArray, forKey: "education")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        else {
            var keychainObjects = NSArray(objects:self.schoolNameLabel.text, self.degreeLabel.text, self.datePicker.date.timeIntervalSince1970, self.endDatePicker.date.timeIntervalSince1970)
            var keychainValues = NSArray(objects:"school","degree", "startDate","endDate")
            let keychainQuery = NSDictionary(objects: keychainObjects as [AnyObject], forKeys: keychainValues as [AnyObject])
            
            ////Add experience into NSUserDefaults
            var loadArray = NSUserDefaults.standardUserDefaults().arrayForKey("education")!
            
            if isEdit {
                loadArray[editNum] = keychainQuery
            }
            else {
                loadArray.append(keychainQuery)
            }
            
            NSUserDefaults.standardUserDefaults().setObject(loadArray, forKey: "education")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func deleteEducationButtonPressed(sender: UIButton) {
        ////Add experience into NSUserDefaults
        var loadArray = NSUserDefaults.standardUserDefaults().arrayForKey("education")!
        
        loadArray.removeAtIndex(editNum)
        
        NSUserDefaults.standardUserDefaults().setObject(loadArray, forKey: "education")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        timer.invalidate()
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        timer.invalidate()
    }
}
