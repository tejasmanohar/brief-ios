import UIKit

class createProfileTableViewController: UITableViewController, UIPageViewControllerDataSource, UITextViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate {
    
    var experienceCount = 0
    var educationCount = 0
    var skillsCount = 0
    
    var profileImage : UIImage!
    
    var experienceArray = []
    var educationArray = []
    var skillsArray = [String]()//["one", "two", "three"]//
    
    var userID = 1
    
    var timer : NSTimer = NSTimer()
    var skillsTimer : NSTimer = NSTimer()
    
    var userInfoDictionary = Dictionary <String, AnyObject>()
    var dictionaryToInitTableView = Dictionary <String, AnyObject>()
    
    var imagePicker = UIImagePickerController()
    var camera = UIImagePickerController()
    
    var indexPathTop = NSIndexPath(forRow: 0, inSection: 0)
    var indexPathFirstName = NSIndexPath(forRow: 1, inSection: 1)
    var indexPathLastName = NSIndexPath(forRow: 2, inSection: 1)
    var indexPathSummary = NSIndexPath(forRow: 4, inSection: 1)
    var hidePlaceholder : Bool = false
    var myViewControllers = Array(count: 3, repeatedValue:UIViewController())
    
    var loadingView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createLoadingView()
        getUserData()
        
        var array = []
        var dict = Dictionary<String, String>()
        NSUserDefaults.standardUserDefaults().setObject(array, forKey: "experience")
        NSUserDefaults.standardUserDefaults().setObject(array, forKey: "education")
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "selectedIndustryName")
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "address")
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey: "locationDictionary")
        
        NSUserDefaults.standardUserDefaults().synchronize()
        
        self.tableView.allowsSelection = true;
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        
        var logo = UIImage(named: "brief-logo-top.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("checkAndSaveNameAndSurname"), userInfo: nil, repeats: true)
        
        skillsTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("checkTheSkills"), userInfo: nil, repeats: true)
    }
    
    func checkAndSaveNameAndSurname() {
        //First Name
        let cellFirstName = self.tableView.cellForRowAtIndexPath(self.indexPathFirstName)
        if cellFirstName != nil {
            var labelFirstName : UITextField = cellFirstName!.viewWithTag(100) as! UITextField
            dictionaryToInitTableView["firstName"] = labelFirstName.text
        }
        //Last Name
        let cellLastName = self.tableView.cellForRowAtIndexPath(self.indexPathLastName)
        if cellLastName != nil {
            var labelLastName : UITextField = cellLastName!.viewWithTag(100) as! UITextField
            dictionaryToInitTableView["lastName"] = labelLastName.text
        }
    }
    
    func createLoadingView () {
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.navigationController?.view.addSubview(loadingView)
        
        var messageView = UIView(frame: CGRectMake((UIScreen.mainScreen().bounds.size.width - 200)/2, (UIScreen.mainScreen().bounds.size.height - 100)/2, 200, 100))
        messageView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        messageView.layer.cornerRadius = 6
        loadingView.addSubview(messageView)
        
        var messageLabel = UILabel(frame: CGRectMake((messageView.frame.size.width - 150)/2, 15, 150, 22))
        messageLabel.text = "Saving Info..."
        messageLabel.textAlignment = NSTextAlignment.Center;
        messageLabel.font = UIFont(name: "avenirnext-medium", size: 18)
        messageLabel.textColor = UIColor(red: 106.0/255.0, green: 172.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        messageView.addSubview(messageLabel)
        
        var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake((messageView.frame.size.width - 50)/2, 45, 50, 50)) as UIActivityIndicatorView
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.color = UIColor(red: 106.0/255.0, green: 172.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        messageView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        loadingView.hidden = true
    }
    
    func reloadInformation() {
        getUserData()
        self.tableView.reloadData()
    }
    
    func getUserData() {
        var googleUrl = NSURL(string: "https://brief-api.herokuapp.com/api/v1/candidates")
        
        var request = NSMutableURLRequest(URL: googleUrl!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String, forHTTPHeaderField: "X-Auth-Token")
        
        var session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if((error) != nil) {
                println(error.localizedDescription)
            }
            
            var strData = NSString(data: data, encoding: NSASCIIStringEncoding)
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            println(json)
            
            if json!.objectForKey("validationErrors") != nil {
                let errorString: AnyObject = json!.objectForKey("validationErrors")!
                
                dispatch_async(dispatch_get_main_queue()) {
                    () -> Void in
                    ///
                    var inputTextFieldEmail: UITextField?
                    var inputTextFieldPassword: UITextField?
                    
                    //Create the AlertController
                    let actionSheetController: UIAlertController = UIAlertController(title: "Thank you", message: "Please enter your email and password to complete the sign in", preferredStyle: .Alert)
                    
                    
                    //Add a text field for email
                    actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
                        // you can use this text field
                        inputTextFieldEmail = textField
                        inputTextFieldEmail?.keyboardType = UIKeyboardType.EmailAddress
                        inputTextFieldEmail?.placeholder = "Email"
                    }
                    
                    //Add a text field for password
                    actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
                        // you can use this text field
                        inputTextFieldPassword = textField
                        inputTextFieldPassword?.secureTextEntry = true
                        inputTextFieldPassword?.placeholder = "Password"
                    }
                    
                    //Create and add the Cancel action
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                        //Do some stuff
                        
                        println("Cancel button pressed")
                        
                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "authToken")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    actionSheetController.addAction(cancelAction)
                    //Create and an option action
                    let nextAction: UIAlertAction = UIAlertAction(title: "Save", style: .Default) { action -> Void in
                        //Do some other stuff
                        
                        if (inputTextFieldEmail!.text != "") {
                            self.setCredentials(["emailAddress": inputTextFieldEmail!.text, "password": inputTextFieldPassword!.text], url: "https://brief-api.herokuapp.com/api/v1/secure/credentials") { (succeeded: Bool, msg: String) -> () in
                            }
                        }
                        else {
                            let alert = UIAlertView()
                            alert.title = "Error"
                            alert.message = "Please enter both email and pasword to the fields above."
                            alert.addButtonWithTitle("Ok")
                            alert.show()
                            
                            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "authToken")
                            NSUserDefaults.standardUserDefaults().synchronize()
                        }
                    }
                    actionSheetController.addAction(nextAction)
                    
                    //Present the AlertController
                    self.presentViewController(actionSheetController, animated: true, completion: nil)
                    ///
                }
            }
            else
            {
                if (json != nil) {
                    self.userInfoDictionary = json as! Dictionary
                    
                    self.fillTheTableView(self.userInfoDictionary)
                }
            }
        })
        
        task.resume()
    }
    
    func fillTheTableView(infoDictionary: Dictionary <String, AnyObject>) {
        let nullValue: AnyObject = NSNull()
        var userIDLocal = infoDictionary["id"] as! Int
        
        userID = userIDLocal
        //User information
        var userInformation : Dictionary <String, AnyObject> = infoDictionary["candidateInfoHelper"] as! Dictionary
        
        //First name
        if userInformation["firstName"] is NSNull {
            println("First name isn't saved")
        }
        else {
            var firstName = userInformation["firstName"] as! String
            println(firstName)
            dictionaryToInitTableView["firstName"] = firstName
        }
        //Last name
        if userInformation["lastName"] is NSNull {
            println("Last name isn't saved")
        }
        else {
            var lastName = userInformation["lastName"] as! String
            println(lastName)
            dictionaryToInitTableView["lastName"] = lastName
        }
        //Location
        if userInformation["location"] is NSNull {
            println("Location isn't saved")
        }
        else {
            var location: AnyObject? = userInformation["location"]
            var city = ""
            var state = ""
            var country = ""
            
            //City
            if location?.objectForKey("cityName") is NSNull {
                println("City isn't saved")
            }
            else {
                println(location!.objectForKey("cityName")!)
                city = location!.objectForKey("cityName") as! String
            }
            //State
            if location?.objectForKey("stateCode") is NSNull {
                println("State isn't saved")
            }
            else {
                println(location!.objectForKey("stateCode")!)
                state = location!.objectForKey("stateCode")as! String
            }
            //Country
            if location?.objectForKey("countryCode") is NSNull {
                println("Country isn't saved")
            }
            else {
                println(location!.objectForKey("countryCode")!)
                country = location!.objectForKey("countryCode") as! String
                
            }
            dictionaryToInitTableView["locationDict"] = location
            dictionaryToInitTableView["address"] = "\(city), \(country)"
            
            var dictLocation : Dictionary<String, String> = ["countryCode" : country, "stateCode" : state, "cityName" : city]
            
            NSUserDefaults.standardUserDefaults().setObject(dictLocation, forKey: "locationDictionary")
            NSUserDefaults.standardUserDefaults().setObject("\(city), \(country)", forKey: "address")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        //Summary
        if userInformation["summary"] is NSNull {
            println("Summary isn't saved")
        }
        else {
            var summary = userInformation["summary"] as! String
            println(summary)
            dictionaryToInitTableView["summary"] = summary
        }
        //Experience
        if userInformation["experience"] is NSNull {
            println("Experience isn't saved")
        }
        else {
            var experience = userInformation["experience"] as! NSArray
            println(experience)
            
            dictionaryToInitTableView["experience"] = experience
            experienceArray = experience
            experienceCount = experienceArray.count
            
            NSUserDefaults.standardUserDefaults().setObject(experience, forKey: "experience")
        }
        //Education
        if userInformation["education"] is NSNull {
            println("Education isn't saved")
        }
        else {
            var education = userInformation["education"] as! NSArray
            println(education)
            dictionaryToInitTableView["education"] = education
            
            educationArray = education
            educationCount = educationArray.count
            
            NSUserDefaults.standardUserDefaults().setObject(education, forKey: "education")
        }
        
        //Skills
        if userInformation["skills"] != nil {
            
            let skillsFromServer : Array<AnyObject> = userInformation["skills"] as! Array
            println(skillsFromServer)
            println(skillsFromServer.count)
            
            var arrayOfSkills : Array<String> = []
            
            if skillsFromServer.count > 0 {
                for index in 0...skillsFromServer.count-1 {
                    let skillDict = skillsFromServer[index] as! Dictionary<String, String>
                    let skillString = skillDict["name"]
                    
                    arrayOfSkills.append(skillString!)
                }
            }
            
            println(arrayOfSkills)
            if arrayOfSkills.count > 0
            {
                skillsArray = arrayOfSkills
                if skillsArray.count != 0 {
                    skillsCount = skillsArray.count
                }
            }
            
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        
        //        println("Here is the data we should init the table view with:\n\(dictionaryToInitTableView)")
        
        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in
            self.tableView.reloadData()
        }
    }
    
    func setCredentials(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: "https://brief-api.herokuapp.com/api/v1/secure/credentials")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "PUT"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String, forHTTPHeaderField: "X-Auth-Token")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            //            println(json)
            
            if json != nil {
                if json!.objectForKey("validationErrors") != nil {
                    let errorString: AnyObject = json!.objectForKey("validationErrors")!
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        let alert = UIAlertView()
                        alert.title = "Error"
                        alert.message = "\(errorString)"
                        alert.addButtonWithTitle("Try again")
                        alert.show()
                        
                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "authToken")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                else {
                    if (json?.objectForKey("authToken") != nil) {
                        let authToken = json?.objectForKey("authToken") as! String
                        
                        NSUserDefaults.standardUserDefaults().setObject(authToken, forKey: "authToken")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        var authTokenStr = NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String
                        
                        //                        println("2 Authorization token is \(authToken)")
                        
                        //                        println("Reload data")
                        self.reloadInformation()
                    }
                }
            }
            
            var msg = "No message"
            
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: "Error")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    if let success = parseJSON["success"] as? Bool {
                        println("Succes: \(success)")
                        postCompleted(succeeded: success, msg: "Logged in.")
                    }
                    return
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, msg: "Error")
                }
            }
        })
        
        task.resume()
    }
    
    override func viewDidAppear(animated: Bool) {
        experienceArray = NSUserDefaults.standardUserDefaults().arrayForKey("experience")!
        experienceCount = experienceArray.count
        
        educationArray = NSUserDefaults.standardUserDefaults().arrayForKey("education")!
        educationCount = educationArray.count
        
        tableView.reloadData()
    }
    
    func textViewDidChange(textView: UITextView) {
        let cellDescription = self.tableView.cellForRowAtIndexPath(self.indexPathSummary)
        var labelDescription : UILabel = cellDescription!.viewWithTag(30) as! UILabel
        
        labelDescription.hidden = count(textView.text) != 0
        
        dictionaryToInitTableView["summary"] = textView.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 5
        }
        else if section == 2 {
            return 1
        }
        else if section == 3 {
            return 1 + experienceCount
        }
        else if section == 4 {
            return 1 + educationCount
        }
        else if section == 5 {
            return 1 + skillsCount
        }
        else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("importCell", forIndexPath: indexPath) as! UITableViewCell
                
                return cell
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("photoCell", forIndexPath: indexPath) as! UITableViewCell
                
                if profileImage != nil {
                    var userImage : UIImageView = cell.viewWithTag(10) as! UIImageView
                    userImage.layer.cornerRadius = userImage.frame.size.width / 2
                    userImage.clipsToBounds = true
                    userImage.image = profileImage
                    
                    let imageText : UILabel = cell.viewWithTag(20) as! UILabel
                    imageText.hidden = true
                }
                
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("nameCell", forIndexPath: indexPath) as! UITableViewCell
                
                var FirstNameTextField : UITextField = cell.viewWithTag(100) as! UITextField
                FirstNameTextField.delegate = self
                
                if dictionaryToInitTableView["firstName"] != nil {
                    FirstNameTextField.text = dictionaryToInitTableView["firstName"] as! String
                }
                
                return cell
            }
            else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("surnameCell", forIndexPath: indexPath) as! UITableViewCell
                
                var LastNameTextField : UITextField = cell.viewWithTag(100) as! UITextField
                LastNameTextField.delegate = self
                
                if dictionaryToInitTableView["lastName"] != nil {
                    LastNameTextField.text = dictionaryToInitTableView["lastName"] as! String
                }
                
                return cell
            }
            else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as! UITableViewCell
                
                var whereAreYouLabel : UILabel = cell.viewWithTag(10) as! UILabel
                
                if NSUserDefaults.standardUserDefaults().objectForKey("address") as! String != "" {
                    whereAreYouLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("address") as? String
                }
                else {
                    whereAreYouLabel.text = "Where are you?"
                }
                
                if dictionaryToInitTableView["address"] != nil {
                    whereAreYouLabel.text = dictionaryToInitTableView["address"] as? String
                }
                
                return cell
            }
            else if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCellWithIdentifier("descriptionCell", forIndexPath: indexPath) as! UITableViewCell
                
                var textView : UITextView = cell.viewWithTag(20) as! UITextView
                textView.delegate = self
                
                if dictionaryToInitTableView["summary"] != nil {
                    textView.text = dictionaryToInitTableView["summary"] as? String
                }
                
                //Create placeholder for text view
                var placeholderLabel = cell.viewWithTag(30) as! UILabel
                placeholderLabel.text = "Tell us a little about yourself..."
                placeholderLabel.font = UIFont(name: "avenirnext-medium", size: 19)
                placeholderLabel.sizeToFit()
                //                placeholderLabel.tag = 30
                
                //                textView.addSubview(placeholderLabel)
                placeholderLabel.frame.origin = CGPointMake(5, textView.font.pointSize / 2)
                placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
                placeholderLabel.hidden = count(textView.text) != 0
                
                return cell
            }
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("IndustryCell", forIndexPath: indexPath) as! UITableViewCell
                
                var industryNameLabel : UILabel = cell.viewWithTag(10) as! UILabel;
                industryNameLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("selectedIndustryName")! as? String
                
                return cell
            }
        }
        else if indexPath.section == 3 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("experienceCell", forIndexPath: indexPath) as! UITableViewCell
                return cell
            }
            else {
                let experienceForCell: AnyObject = experienceArray[indexPath.row-1]
                
                //                println(experienceArray[indexPath.row-1])
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MMM YYYY"
                
                var startString = ""
                var endString = "Current"
                //Start string from timestamp
                var startNum = experienceForCell.objectForKey("startDate") as! NSTimeInterval
                if startNum > 10000000000 {
                    startNum = startNum/1000
                }
                var startDate = NSDate(timeIntervalSince1970: startNum)
                
                startString = dateFormatter.stringFromDate(startDate)
                //
                var position = experienceForCell.objectForKey("position") as! String
                var company = experienceForCell.objectForKey("company") as! String
                //End date from timestamp
                if experienceForCell.objectForKey("endDate") != "" {
                    var endNum = experienceForCell.objectForKey("endDate") as! NSTimeInterval
                    
                    if endNum > 10000 {
                        if endNum > 10000000000 {
                            endNum = endNum/1000
                        }
                        var endDate = NSDate(timeIntervalSince1970: endNum)
                        
                        endString = dateFormatter.stringFromDate(endDate)
                    }
                }
                //
                let cell = tableView.dequeueReusableCellWithIdentifier("eAndeInfoCell", forIndexPath: indexPath) as! UITableViewCell
                
                cell.textLabel?.text = position
                cell.detailTextLabel?.text = "\(company), \(startString) - \(endString)"
                
                return cell
            }
        }
        else if indexPath.section == 4 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("educationCell", forIndexPath: indexPath) as! UITableViewCell
                
                return cell
            }
            else {
                let educationForCell: AnyObject = educationArray[indexPath.row-1]
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "YYYY"
                
                var startString = ""
                var endString = "Current"
                //Start string from timestamp
                var startNum = educationForCell.objectForKey("startDate") as! NSTimeInterval
                if startNum > 10000000000 {
                    startNum = startNum/1000
                }
                var startDate = NSDate(timeIntervalSince1970: startNum)
                
                startString = dateFormatter.stringFromDate(startDate)
                //
                //End date from timestamp
                if educationForCell.objectForKey("endDate") != "" {
                    var endNum = educationForCell.objectForKey("endDate") as! NSTimeInterval
                    if endNum > 10000 {
                        if endNum > 10000000000 {
                            endNum = endNum/1000
                        }
                        var endDate = NSDate(timeIntervalSince1970: endNum)
                        
                        endString = dateFormatter.stringFromDate(endDate)
                    }
                }
                
                var school = educationForCell.objectForKey("school") as! String
                var degree = educationForCell.objectForKey("degree") as! String
                
                let cell = tableView.dequeueReusableCellWithIdentifier("eAndeInfoCell", forIndexPath: indexPath) as! UITableViewCell
                
                cell.textLabel?.text = school
                cell.detailTextLabel?.text = "\(degree), \(startString) - \(endString)"
                
                return cell
            }
        }
        else if indexPath.section == 5 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("skillsCell", forIndexPath: indexPath) as! UITableViewCell
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("skillsInfoCell", forIndexPath: indexPath) as! UITableViewCell
                var skillNameTextField : UITextField = cell.viewWithTag(500) as! UITextField
                if skillsArray.count > indexPath.row-1 {
                    skillNameTextField.text = skillsArray[indexPath.row-1]
                }
                
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("skillsInfoCell", forIndexPath: indexPath) as! UITableViewCell
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 170
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            if profileImage != nil {
                return 130
            }
            else {
                return 170
            }
        }
        else if indexPath.section == 1 && indexPath.row == 4 {
            return 132
        }
        else {
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 236.0/255.0, green: 238.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        header.textLabel.textColor = UIColor(red: 126.0/255.0, green: 127.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        header.textLabel.font = UIFont(name: "avenirnext-demibold", size: 13)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Let’s get to know each other."
        }
        else if section == 2 {
            return "What do you do?"
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 || section == 2 {
            return 40.0
        }
        else {
            return 0
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        dismissViewControllerAnimated(true, completion: nil)
        
        profileImage = image
        
        //Save the selected image to the device's directory
        let fileManager = NSFileManager.defaultManager()
        
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        var filePathToWrite = "\(paths)/UserImage.png"
        
        var imageData: NSData = UIImagePNGRepresentation(image)
        
        fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
        //
        
        view.endEditing(true)
        
        tableView.reloadData()
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        imagePicker.navigationBar.tintColor = UIColor.whiteColor()
        imagePicker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        imagePicker.navigationBar.barTintColor = UIColor(red: 106.0/255.0, green: 172.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 3 && indexPath.section == 1 {
            self.performSegueWithIdentifier("whereAreYou", sender: self)
        }
        else if indexPath.row == 0 && indexPath.section == 1 {
            let alert = UIAlertController(title: "Upload Profile Image:", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
            let libButton = UIAlertAction(title: "Select From Library", style: UIAlertActionStyle.Default) { (alert) -> Void in
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = true
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
                let cameraButton = UIAlertAction(title: "Take A Photo", style: UIAlertActionStyle.Default) { (alert) -> Void in
                    println("Take Photo")
                    self.camera.sourceType = UIImagePickerControllerSourceType.Camera
                    self.camera.delegate = self
                    self.camera.allowsEditing = true
                    self.presentViewController(self.camera, animated: true, completion: nil)
                }
                alert.addAction(cameraButton)
            } else {
                println("Camera not available")
                
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                println("Cancel Pressed")
            }
            
            alert.addAction(libButton)
            alert.addAction(cancelButton)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if indexPath.row == 0 && indexPath.section == 0 {
            println("Top Cell")
        }
        else if indexPath.row == 0 && indexPath.section == 1 {
            println("Add Photo")
        }
        else if indexPath.row == 0 && indexPath.section == 2 {
            println("Select Industry screen")
            
            self.performSegueWithIdentifier("ListView", sender: self)
        }
        else if indexPath.section == 3 {
            if indexPath.row == 0 {
                NSUserDefaults.standardUserDefaults().setInteger(100, forKey: "editExperience")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //                println("Edit Experience screen")
                self.performSegueWithIdentifier("addExperience", sender: self)
            }
            else {
                NSUserDefaults.standardUserDefaults().setInteger(indexPath.row-1, forKey: "editExperience")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //                println("Edit Experience screen for editing the \(indexPath.row - 1) cell")
                self.performSegueWithIdentifier("addExperience", sender: self)
            }
        }
        else if indexPath.section == 4 {
            if indexPath.row == 0 {
                NSUserDefaults.standardUserDefaults().setInteger(100, forKey: "editEducation")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //                println("Edit Education screen")
                self.performSegueWithIdentifier("addEducation", sender: self)
            }
            else {
                NSUserDefaults.standardUserDefaults().setInteger(indexPath.row-1, forKey: "editEducation")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //                println("Edit Education screen for editing the \(indexPath.row - 1) cell")
                self.performSegueWithIdentifier("addEducation", sender: self)
            }
        }
        else if indexPath.row == 0 && indexPath.section == 5 {
            view.endEditing(true)
            
            self.addTheRowForSkill()
        }
        else
        {
            println("You've selected the \(indexPath.row), \(indexPath.section)")
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func addTheRowForSkill() {
        if skillsCount == 0 {
            skillsCount = 1
        }
        else {
            skillsCount = skillsArray.count + 1
        }
        
        view.endEditing(true)
        
        var newTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("scrollToTheBottomOfTableView"), userInfo: nil, repeats: false)
    }
    
    func scrollToTheBottomOfTableView()
    {
        tableView.reloadData()
        
        if tableView.contentSize.height > tableView.frame.size.height
        {
            let offset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.size.height)
            tableView.setContentOffset(offset, animated: true)
        }
    }
    
    func checkTheSkills() {
        var endNum = 0
        if skillsCount == 0 {
            endNum = 0
        }
        else {
            endNum = skillsCount-1
        }
        
        for index in 0...endNum {
            let skillCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index+1, inSection: 5))
            if skillCell != nil {
                let skillNameTextField : UITextField = skillCell!.viewWithTag(500) as! UITextField
                if skillNameTextField.text != nil {
                    if skillNameTextField.text != "" {
                        if skillsArray.count < index+1 {
                            skillsArray.append(skillNameTextField.text)
                        }
                        else {
                            skillsArray[index] = skillNameTextField.text
                        }
                    }
                    else {
                        if skillsArray.count >= index+1 {
                            skillsArray[index] = skillNameTextField.text
                        }
                    }
                }
            }
        }
        
        //        println(skillsArray)
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        timer.invalidate()
        skillsTimer.invalidate()
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("isEditProfile") {
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "authToken")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "openPageView" {
            let pvc = segue.destinationViewController as! UIPageViewController
            pvc.dataSource = self
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            var vc0 = storyboard.instantiateViewControllerWithIdentifier("Settings") as! UINavigationController
            var vc1 = storyboard.instantiateViewControllerWithIdentifier("Search") as! UINavigationController
            var vc2 = storyboard.instantiateViewControllerWithIdentifier("Messages") as! UINavigationController
            
            self.myViewControllers = [vc0, vc1, vc2]
            pvc.setViewControllers([myViewControllers[1]], direction:.Forward, animated:true, completion:nil)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var currentIndex =  find(self.myViewControllers, viewController)!+1
        if currentIndex >= self.myViewControllers.count {
            return nil
        }
        return self.myViewControllers[currentIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var currentIndex =  find(self.myViewControllers, viewController)!-1
        if currentIndex < 0 {
            return nil
        }
        return self.myViewControllers[currentIndex]
    }
    
    func getSkillToTheRightFormat()
    {
        //        println("We've got an array - \(skillsArray)")
        
        if skillsArray.count > 0 {
            for index in 0...skillsArray.count-1 {
                if skillsArray[index] as String == "" {
                    skillsArray.removeAtIndex(index)
                }
            }
        }
        
        //        println("Array to save - \(skillsArray)")
        
        if skillsArray.count > 0 {
            var array: [Dictionary<String, String>] = []
            for index in 0...skillsArray.count-1 {
                let dictionary : Dictionary<String, String> = ["skill" : skillsArray[index]]
                array.append(dictionary)
            }
            let skillDictionary : Dictionary<String, Array<Dictionary<String, String>>> = ["skills" : array]
            
            //            println(skillDictionary)
            
            self.saveSkills(skillDictionary, url: "https://brief-api.herokuapp.com/api/v1/candidates/skills") { (succeeded: Bool, msg: String) -> () in
            }
        }
    }
    
    func saveSkills(params : Dictionary<String, Array<Dictionary <String, String>>>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: "https://brief-api.herokuapp.com/api/v1/candidates/skills")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "PUT"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String, forHTTPHeaderField: "X-Auth-Token")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            if json != nil {
                if json!.objectForKey("validationErrors") != nil {
                    let errorString: AnyObject = json!.objectForKey("validationErrors")!
                    println(errorString)
                }
                else {
                    println("Skills have been saved: \(json!)")
                }
            }
            
            var msg = ""
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: "Error")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    if let success = parseJSON["success"] as? Bool {
                        println("Succes: \(success)")
                        postCompleted(succeeded: success, msg: "Logged in.")
                    }
                    return
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, msg: "Error")
                }
            }
        })
        task.resume()
    }
    
    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.loadingView.hidden = false
        
        getSkillToTheRightFormat()
        
        var firstName = ""
        var lastName = ""
        var summary = ""
        var education : [Dictionary <String, String>] = []
        var experience : [Dictionary <String, String>] = []
        var location = Dictionary <String, String>()
        
        var isFilled = true
        
        var nameError = ""
        var surnameError = ""
        var locationError = ""
        var summaryError = ""
        var experienceError = ""
        var educationError = ""
        
        if dictionaryToInitTableView["firstName"] != nil
        {
            var firstNameSaved = dictionaryToInitTableView["firstName"] as! String
            
            if firstNameSaved != "" {
                firstName = firstNameSaved
            }
            else {
                isFilled = false
                nameError = "- First Name field is empty\n"
            }
        }
        else {
            isFilled = false
            nameError = "- First Name field is empty\n"
        }
        
        if dictionaryToInitTableView["lastName"] != nil {
            
            var lastNameSaved = dictionaryToInitTableView["lastName"] as! String
            
            
            if lastNameSaved != "" {
                lastName = lastNameSaved
            }
            else {
                isFilled = false
                surnameError = "- Last Name field is empty\n"
            }
        }
        else {
            isFilled = false
            surnameError = "- Last Name field is empty\n"
        }
        
        
        if dictionaryToInitTableView["summary"] != nil {
            var summaryTextSaved = dictionaryToInitTableView["summary"] as! String
            
            if summaryTextSaved != "" {
                summary = summaryTextSaved
            }
            else {
                isFilled = false
                summaryError = "- Summary field is empty\n"
            }
        }
        else {
            isFilled = false
            summaryError = "- Summary field is empty\n"
        }
        
        //        println("Education - \(educationArray)")
        if educationArray != [] {
            for index in 0...educationArray.count-1 {
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "YYYY"
                
                var startNum = educationArray[index].objectForKey("startDate") as! NSTimeInterval
                if startNum > 10000000000 {
                    startNum = startNum/1000
                }
                var startDate = NSDate(timeIntervalSince1970: startNum)
                var startString = dateFormatter.stringFromDate(startDate)
                
                var endString = ""
                if educationArray[index].objectForKey("endDate") != "" {
                    var endNum = educationArray[index].objectForKey("endDate") as! NSTimeInterval
                    if endNum > 10000000000 {
                        endNum = endNum/1000
                    }
                    var endDate = NSDate(timeIntervalSince1970: endNum)
                    endString = dateFormatter.stringFromDate(endDate)
                    
                }
                
                var dict : Dictionary <String, String> = ["startDate" : startString, "endDate" : endString, "school" : educationArray[index].objectForKey("school") as! String, "degree" : educationArray[index].objectForKey("degree") as! String]
                education.append(dict)
            }
        }
        
        //        println("Experience - \(experienceArray)")
        if experienceArray != [] {
            for index in 0...experienceArray.count-1 {
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "YYYY-MM"
                
                var startNum = experienceArray[index].objectForKey("startDate") as! NSTimeInterval
                if startNum > 10000000000 {
                    startNum = startNum/1000
                }
                var startDate = NSDate(timeIntervalSince1970: startNum)
                var startString = dateFormatter.stringFromDate(startDate)
                
                var endString = ""
                if experienceArray[index].objectForKey("endDate") != "" {
                    var endNum = experienceArray[index].objectForKey("endDate") as! NSTimeInterval
                    if endNum > 10000000000 {
                        endNum = endNum/1000
                    }
                    var endDate = NSDate(timeIntervalSince1970: endNum)
                    endString = dateFormatter.stringFromDate(endDate)
                    
                }
                
                var dict : Dictionary <String, String> = ["startDate" : startString, "endDate" : endString, "position" : experienceArray[index].objectForKey("position") as! String, "company" : experienceArray[index].objectForKey("company") as! String]
                experience.append(dict)
            }
        }
        
        var emptyDict = Dictionary <String, String>()
        
        var locationDictionary : Dictionary<String, String> = NSUserDefaults.standardUserDefaults().objectForKey("locationDictionary") as! Dictionary
        //        println("Location - \(locationDictionary)")
        if locationDictionary != emptyDict {
            location = locationDictionary
        }
        else {
            isFilled = false
            locationError = "- Location is empty\n"
        }
        
        println(isFilled)
        
        if isFilled {
            var saveDictionary = ["firstName" : firstName, "lastName" : lastName, "summary" : summary, "education" : education, "experience" : experience, "location" : location] as Dictionary <String, AnyObject>
            println(saveDictionary)
            
            self.saveUserInfo(saveDictionary, url: "https://brief-api.herokuapp.com/api/v1/candidates") { (succeeded: Bool, msg: String) -> () in
            }
        }
        else {
            let alert = UIAlertView()
            alert.title = "Please fix the following problems"
            alert.message = "\(nameError)\(surnameError)\(locationError)\(summaryError)\(experienceError)\(educationError)"
            alert.addButtonWithTitle("Try again")
            alert.show()
            
            dispatch_async(dispatch_get_main_queue()) {
                () -> Void in
                self.loadingView.hidden = true
            }
        }
    }
    
    func saveUserInfo(params : Dictionary<String, AnyObject>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: "https://brief-api.herokuapp.com/api/v1/candidates")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "PUT"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String, forHTTPHeaderField: "X-Auth-Token")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            if json != nil {
                if json!.objectForKey("validationErrors") != nil {
                    let errorString: AnyObject = json!.objectForKey("validationErrors")!
                    
                    println(errorString)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        let alert = UIAlertView()
                        alert.title = "Error"
                        alert.message = "\(errorString)"
                        alert.addButtonWithTitle("Try Again")
                        alert.show()
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        self.loadingView.hidden = true
                    }
                }
                else {
                    println("Here is the saved data: \(json!)")
                    
                    var name = json?.objectForKey("candidateInfoHelper")?.objectForKey("firstName") as! String
                    NSUserDefaults.standardUserDefaults().setObject(name, forKey: "userNameSaved")
                    //Stop the timers
                    self.timer.invalidate()
                    self.skillsTimer.invalidate()
                    
                    NSUserDefaults.standardUserDefaults().setObject("Yes", forKey: "loggedIn")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    if NSUserDefaults.standardUserDefaults().boolForKey("isEditProfile") {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else {
                        self.performSegueWithIdentifier("openPageView", sender: self)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        self.loadingView.hidden = true
                    }
                }
            }
            
            var msg = ""
            
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: "Error")
                
                dispatch_async(dispatch_get_main_queue()) {
                    () -> Void in
                    self.loadingView.hidden = true
                }
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    if let success = parseJSON["success"] as? Bool {
                        println("Succes: \(success)")
                        postCompleted(succeeded: success, msg: "Logged in.")
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            () -> Void in
                            self.loadingView.hidden = true
                        }
                    }
                    return
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, msg: "Error")
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        self.loadingView.hidden = true
                    }
                }
            }
        })
        task.resume()
    }
}
