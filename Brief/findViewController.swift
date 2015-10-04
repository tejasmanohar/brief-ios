import UIKit

class findViewController: UIViewController, UIPageViewControllerDataSource {
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var myViewControllers = Array(count: 3, repeatedValue:UIViewController())
    var dataString = ""
    @IBOutlet weak var detailsButton: UIButton!
    var timer : NSTimer = NSTimer()
    var topCardID = 100000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var logo = UIImage(named: "brief-logo-top.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        // Do any additional setup after loading the view.
        self.detailsButton.hidden = true
        activityIndicator.hidden = false
        loadingLabel.hidden = false
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("getTheTopCardID"), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        getJobs()
    }
    
    func getTheTopCardID() {
        topCardID = NSUserDefaults.standardUserDefaults().integerForKey("topCardID")
        if topCardID != 100000 && topCardID != 0 {
            detailsButton.enabled = true
        }
        else {
            detailsButton.enabled = false
        }
    }
    
    @IBAction func buttonPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("openDetails", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            pvc.setViewControllers([myViewControllers[0]], direction:.Forward, animated:true, completion:nil)
        }
        else if sender.tag == 2000 {
            let pvc = segue.destinationViewController as! UIPageViewController
            
            pvc.dataSource = self
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            
            var vc0 = storyboard.instantiateViewControllerWithIdentifier("Settings")as! UINavigationController
            var vc1 = storyboard.instantiateViewControllerWithIdentifier("Search")as! UINavigationController
            var vc2 = storyboard.instantiateViewControllerWithIdentifier("Messages")as! UINavigationController
            
            self.myViewControllers = [vc0, vc1, vc2]
            
            pvc.setViewControllers([myViewControllers[2]], direction:.Forward, animated:true, completion:nil)
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
    
    func getJobs() {
        var jobsURL = NSURL(string: "https://brief-api.herokuapp.com/api/v1/jobs")
        
        var request = NSMutableURLRequest(URL: jobsURL!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String, forHTTPHeaderField: "X-Auth-Token")
        println("Token!")
        println(NSUserDefaults.standardUserDefaults().stringForKey("authToken")!)
        
        var session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if((error) != nil) {
                println(error.localizedDescription)
            }
            
            var strData = NSString(data: data, encoding: NSASCIIStringEncoding)
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? Array <AnyObject>
            if json != nil {
                if json!.count > 0 {
                    for index in 0...json!.count-1 {
                        var dict = json![index] as! Dictionary <String, AnyObject>
                    
                        if dict["cityName"] is NSNull {
                            dict["cityName"] = ""
                        }
                        if dict["countryCode"] is NSNull {
                            dict["countryCode"] = ""
                        }
                        if dict["stateCode"] is NSNull {
                            dict["stateCode"] = ""
                        }
                        json![index] = dict
                    }
                }
                ///
                NSUserDefaults.standardUserDefaults().setObject(json, forKey: "jobsArray")
                NSUserDefaults.standardUserDefaults().synchronize()
//                println("New JSON found")
//                println(json)
//                println("End of JSON")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                () -> Void in
                var draggableBackground: DraggableViewBackground = DraggableViewBackground(frame: self.view.frame)
                self.view.addSubview(draggableBackground)
                
                self.view.bringSubviewToFront(self.detailsButton)
                self.detailsButton.hidden = false
                self.activityIndicator.hidden = true
                self.loadingLabel.hidden = false
            }
            
            //Loading the jobs view
        })
        task.resume()
    }
}
