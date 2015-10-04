import UIKit

class settingsTableViewController: UITableViewController, UIPageViewControllerDataSource {
    
    var myViewControllers = Array(count: 3, repeatedValue:UIViewController())
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        nav?.titleTextAttributes = [NSFontAttributeName: UIFont(name: "avenirnext-demibold", size: 22)!]

        loadNameAndImage()
    }
    
    override func viewDidAppear(animated: Bool) {
        loadNameAndImage()
    }
    
    func loadNameAndImage() {
        ///
        let fileManager = NSFileManager.defaultManager()
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var getImagePath = paths.stringByAppendingPathComponent("UserImage.png")
        //
        if (fileManager.fileExistsAtPath(getImagePath))
        {
            //Pick Image and Use accordingly
            var imageis: UIImage = UIImage(contentsOfFile: getImagePath)!
            
            userImage.image = imageis
            
            userImage.layer.cornerRadius = userImage.frame.size.width / 2
            userImage.clipsToBounds = true
            
            let data: NSData = UIImagePNGRepresentation(imageis)
        }
        else
        {
            println("User image isn't set - show the standard smile image");
            
        }
        
        var name = NSUserDefaults.standardUserDefaults().objectForKey("userNameSaved") as! String
        userName.text = name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 3
        }
        else if section == 2 {
            return 0
        }
        else {
            return 0
        }
    }
    @IBAction func editProfileButtonPressed(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isEditProfile")
        NSUserDefaults.standardUserDefaults().synchronize()
        performSegueWithIdentifier("editProfile", sender: self)
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 236.0/255.0, green: 238.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        header.textLabel.textColor = UIColor(red: 126.0/255.0, green: 127.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        header.textLabel.font = UIFont(name: "avenirnext-demibold", size: 13)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 500
        }
        else {
            return 40
        }
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
    
    @IBAction func logOutButtonPressed(sender: UIBarButtonItem) {
        //Save the selected image to the device's directory
        let fileManager = NSFileManager.defaultManager()
        
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        var filePathToWrite = "\(paths)/UserImage.png"
                
        var imageData: NSData = UIImagePNGRepresentation(UIImage(named: "addPhoto.png"))
        
        fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
        //
        
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "authToken")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "loggedIn")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        performSegueWithIdentifier("logOutToTheSignIn", sender: self)
    }
}