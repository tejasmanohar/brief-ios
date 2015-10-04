import UIKit

class messagesListTableViewController: UITableViewController, UIPageViewControllerDataSource {
    
    var myViewControllers = Array(count: 3, repeatedValue:UIViewController())
    var timer : NSTimer = NSTimer()
    var converstations = [AnyObject]()
    var loadingView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createLoadingView()
        
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        nav?.titleTextAttributes = [NSFontAttributeName: UIFont(name: "avenirnext-demibold", size: 22)!]
        
        self.loadingView.hidden = false
        getConversations()
    }
    
    override func viewDidAppear(animated: Bool) {
        println("Update info")
        getConversations()
    }
    
    func createLoadingView () {
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.navigationController?.view.addSubview(loadingView)
        
        var messageView = UIView(frame: CGRectMake((UIScreen.mainScreen().bounds.size.width - 200)/2, (UIScreen.mainScreen().bounds.size.height - 100)/2, 200, 100))
        messageView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        messageView.layer.cornerRadius = 6
        loadingView.addSubview(messageView)
        
        var messageLabel = UILabel(frame: CGRectMake((messageView.frame.size.width - 200)/2, 15, 200, 22))
        messageLabel.text = "Loading Messages..."
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1//2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if section == 0 {
            return self.converstations.count
        }
        else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        var currentConversation = self.converstations[indexPath.row] as! Dictionary<String, AnyObject>
        
        (cell.contentView.viewWithTag(101) as! UIImageView).image = UIImage(named: "dropboxIcon")//UIImage(named: (self.dictionary["icon"] as? String)!)
        (cell.contentView.viewWithTag(102) as! UILabel).text = currentConversation["title"] as? String//self.dictionary["company"] as? String
        (cell.contentView.viewWithTag(103) as! UILabel).text = "1d ago"
        (cell.contentView.viewWithTag(104) as! UILabel).text = "Great work for best developers!"
        // Configure the cell...
        let unreadMessages = currentConversation["unread"] as! Int
        if unreadMessages > 0 {
            (cell.contentView.viewWithTag(105) as! UIImageView).hidden = false
            (cell.contentView.viewWithTag(106) as! UILabel).hidden = false
            (cell.contentView.viewWithTag(106) as! UILabel).text = "\(unreadMessages)"
        }
        else {
            (cell.contentView.viewWithTag(105) as! UIImageView).hidden = true
            (cell.contentView.viewWithTag(106) as! UILabel).hidden = true
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            var text = "No Matched Companies"
            if self.converstations.count == 1 {
                text = "1 Matched Company"
            }
            else if self.converstations.count > 1 {
                text = "\(self.converstations.count) Matched Companies"
            }
            return text
        }
        else {
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 236.0/255.0, green: 238.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        header.textLabel.textColor = UIColor(red: 126.0/255.0, green: 127.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        header.textLabel.font = UIFont(name: "avenirnext-demibold", size: 13)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSUserDefaults.standardUserDefaults().setObject(self.converstations[indexPath.row]["id"] as! NSNumber, forKey: "selectedConversation")
        NSUserDefaults.standardUserDefaults().setObject(self.converstations[indexPath.row]["title"] as! String, forKey: "selectedConversationTitle")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        self.performSegueWithIdentifier("openMessage", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if sender.tag == nil {
        }
        else if sender.tag == 1000 {
            let pvc = segue.destinationViewController as! UIPageViewController
            
            pvc.dataSource = self
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            
            var vc0 = storyboard.instantiateViewControllerWithIdentifier("Settings")as! UINavigationController
            var vc1 = storyboard.instantiateViewControllerWithIdentifier("Search")as! UINavigationController
            var vc2 = storyboard.instantiateViewControllerWithIdentifier("Messages")as! UINavigationController
            
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
    
    func getConversations() {
        var jobsURL = NSURL(string: "https://brief-api.herokuapp.com/api/v1/conversations")
        
        var request = NSMutableURLRequest(URL: jobsURL!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String, forHTTPHeaderField: "X-Auth-Token")
        
        var session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if((error) != nil) {
                println(error.localizedDescription)
                
                dispatch_async(dispatch_get_main_queue()) {
                    () -> Void in
                    self.loadingView.hidden = true
                }
            }
            
            var strData = NSString(data: data, encoding: NSASCIIStringEncoding)
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? Array <AnyObject>
            if json != nil {
                println("Conversations:")
                if json!.count > 0 {
                    self.converstations = json!
                    println(self.converstations)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        self.tableView.reloadData()
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    () -> Void in
                    self.loadingView.hidden = true
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    () -> Void in
                    self.loadingView.hidden = true
                }
            }
        })
        task.resume()
    }
}