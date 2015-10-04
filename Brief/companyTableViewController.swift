import UIKit

class companyTableViewController: UITableViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    var topCardID = 100000
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///Setting up navigation bar
        var logo = UIImage(named: "brief-logo-top.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        pageControl.currentPage = 0
        
        let rightView = UIView(frame:  CGRectMake(0, 0, 63, 27))
        
        let checkButton = UIButton(frame: CGRectMake(0,0,27, 27))
        checkButton.setImage(UIImage(named: "checkButton"), forState: UIControlState.Normal)
        checkButton.addTarget(self, action: "checkButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        rightView.addSubview(checkButton)
        
        let cancelButton = UIButton(frame: CGRectMake(36,0,27, 27))
        cancelButton.setImage(UIImage(named: "cancelButton"), forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "cancelButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        rightView.addSubview(cancelButton)
        
        let rightBtn = UIBarButtonItem(customView: rightView)
        self.navigationItem.rightBarButtonItem = rightBtn;
        //
        
        view.setNeedsLayout()
        view.layoutIfNeeded();
        //Create the scroll view
        
        for index in 0..<5 {
            var frame:CGRect = CGRectMake(UIScreen.mainScreen().bounds.size.width, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.width)
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            self.scrollView.pagingEnabled = true
            
            var subView = UIView(frame: frame)
            subView.backgroundColor = UIColor(patternImage: UIImage(named: "image")!)
            
            self.scrollView .addSubview(subView)
        }
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 5, self.scrollView.frame.size.height)
        
        topCardID = NSUserDefaults.standardUserDefaults().integerForKey("topCardID")
        println(topCardID)
        
        if NSUserDefaults.standardUserDefaults().objectForKey("jobsArray") != nil {
            var jobs = NSUserDefaults.standardUserDefaults().objectForKey("jobsArray") as! Array<AnyObject>
            
            for index in 0...jobs.count-1 {
                let job : Dictionary<String, AnyObject> = jobs[index] as! Dictionary<String, AnyObject>
                
                let id = job["id"] as! Int
                if id == topCardID {
                    let title = job["title"] as! String
                    let city = job["cityName"] as! String
                    let state = job["stateCode"] as! String
                    let country = job["countryCode"] as! String
                    let experience = job["experience"] as! Int
                    let minSalary = job["minSalary"] as! Int
                    let maxSalary = job["maxSalary"] as! Int
                    let companyId = job["companyId"] as! Int
                    let description = job["description"] as! String
                    let id = job["id"] as! Int
                    //Title
                    println(title)
                    //Location
                    var location = ""
                    if state != "" {
                        if city != "" {
                            location = "\(city), \(state)"
                        }
                        else {
                            if country != "" {
                                location = "\(state), \(country)"
                            }
                        }
                    }
                    else {
                        if city != "" {
                            location = city
                        }
                        else {
                            if country != "" {
                                location = country
                            }
                            else {
                                location = "Unknown"
                            }
                        }
                    }
                    println(location)
                    //Experience
                    var experienceString = ""
                    if experience == 1 {
                        experienceString = "1 year"
                    }
                    else {
                        experienceString = "\(experience) years"
                    }
                    println(experienceString)
                    //Salary
                    var salary = ""
                    salary = "\(minSalary/1000)-\(maxSalary/1000)k+"
                    println(salary)
                    
                    titleLabel.text = title
                    locationLabel.text = location
                    experienceLabel.text = experienceString
                    salaryLabel.text = salary
                    descriptionLabel.text = description
                    descriptionLabel.sizeToFit()
                }
            }
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        pageControl.currentPage = page
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelButtonPressed(sender: UIBarButtonItem) {
        println("Cancel")
        dismissAJob(topCardID)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkButtonPressed(sender: UIBarButtonItem) {
        println("Check")
        applyForJob(topCardID)
        self.dismissViewControllerAnimated(true, completion: nil)
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
        return 4
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UIScreen.mainScreen().bounds.size.width
        }
        else if indexPath.row == 1 {
            return 85
        }
        else if indexPath.row == 2 {
            return 65
        }
        else if indexPath.row == 3 {
            return 135
        }
        else {
            return 44
        }
    }
    
    //Apply for a Job
    func applyForJob(jobID : Int) {
        //Save the id - not to show it second time if it's done
        
        var jobsURL = NSURL(string: "https://brief-api.herokuapp.com/api/v1/jobs/\(jobID)/applications/apply")
        
        var request = NSMutableURLRequest(URL: jobsURL!)
        request.HTTPMethod = "PUT"
        request.addValue(NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String, forHTTPHeaderField: "X-Auth-Token")
        
        var session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if((error) != nil) {
                println(error.localizedDescription)
            }
            
            var strData = NSString(data: data, encoding: NSASCIIStringEncoding)
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? Dictionary <String, AnyObject>
            if json != nil {
                println(json)
            }
        })
        task.resume()
    }
    
    //Dismiss a Job
    func dismissAJob(jobID : Int) {
        //Save the id - not to show it second time if it's done
        
        var jobsURL = NSURL(string: "https://brief-api.herokuapp.com/api/v1/jobs/\(jobID)/applications/dismiss")
        
        var request = NSMutableURLRequest(URL: jobsURL!)
        request.HTTPMethod = "PUT"
        request.addValue(NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String, forHTTPHeaderField: "X-Auth-Token")
        
        var session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if((error) != nil) {
                println(error.localizedDescription)
            }
            
            var strData = NSString(data: data, encoding: NSASCIIStringEncoding)
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? Dictionary <String, AnyObject>
            if json != nil {
                println(json)
            }
        })
        task.resume()
    }
}
