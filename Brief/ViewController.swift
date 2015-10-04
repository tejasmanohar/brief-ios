import UIKit
import CoreLocation
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class ViewController: UIViewController, UIPageViewControllerDataSource, UINavigationControllerDelegate {
    
    var dict : NSDictionary!
    
    //Creating outlets for all the graphic elements
    @IBOutlet weak var briefLogo: UIImageView!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var emailAndUsernameBg: UIImageView!
    @IBOutlet weak var letterImage: UIImageView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var greyLine: UIImageView!
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var whiteLine: UIImageView!
    @IBOutlet weak var facebookSignInButton: UIButton!
    @IBOutlet weak var facebookLogo: UIImageView!
    @IBOutlet weak var twitterSignInButton: UIButton!
    @IBOutlet weak var twitterLogo: UIImageView!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var signUpWithEmailButton: UIButton!
    let locationManager = CLLocationManager()
    
    var loadingView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
    
    var myViewControllers = Array(count: 3, repeatedValue:UIViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createLoadingView()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if NSUserDefaults.standardUserDefaults().objectForKey("authToken") != nil && NSUserDefaults.standardUserDefaults().objectForKey("loggedIn") != nil {
            println("User is logged in")
            
            var loadingView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
            loadingView.backgroundColor = UIColor(red: 106.0/255.0, green: 172.0/255.0, blue: 250.0/255.0, alpha: 1.0)
            self.view.addSubview(loadingView)
            
            let imageName = "Brief-emblem.png"
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image!)
            
            imageView.frame = CGRect(x: (UIScreen.mainScreen().bounds.size.width - 225)/2, y: (UIScreen.mainScreen().bounds.size.height - 120)/2, width: 225, height: 120)
            loadingView.addSubview(imageView)
        }
        else {
            println("User needs to login")
        }
    }
    
    func createLoadingView () {
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.view.addSubview(loadingView)
        
        var messageView = UIView(frame: CGRectMake((UIScreen.mainScreen().bounds.size.width - 200)/2, (UIScreen.mainScreen().bounds.size.height - 100)/2, 200, 100))
        messageView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        messageView.layer.cornerRadius = 6
        loadingView.addSubview(messageView)
        
        var messageLabel = UILabel(frame: CGRectMake((messageView.frame.size.width - 100)/2, 15, 100, 22))
        messageLabel.text = "Signing In..."
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
    
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in
            self.loadingView.hidden = true
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey("authToken") != nil && NSUserDefaults.standardUserDefaults().objectForKey("loggedIn") != nil {
            [performSegueWithIdentifier("userLoggedInSkipTheLogin", sender: nil)]
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "userLoggedInSkipTheLogin" {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backgroundTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func signInButtonPressed(sender: UIButton) {
        self.view.endEditing(true)
        loadingView.hidden = false
        
        if self.loginTextField.text != "" && self.passwordTextField.text != "" {
            self.post(["password": self.passwordTextField.text, "emailAddress": self.loginTextField.text], url: "https://brief-api.herokuapp.com/api/v1/secure/singin") { (succeeded: Bool, msg: String) -> () in
            }
        }
        else {
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = "Please enter both email and pasword to the fields above."
            alert.addButtonWithTitle("Ok")
            alert.show()
            
            loadingView.hidden = true
        }
    }
    
    @IBAction func signInWithTwitterButtonPressed(sender: UIButton) {
        self.view.endEditing(true)
        loadingView.hidden = false
        
        self.twitterSignIn(["accessToken": "3288278961-XxIpyL2nvzzQVih4bepeFImjjQrtCd7kFHyuKyh", "accessSecret": "GQKAkeSvCeqMEFIYwz088QBkm8aNjf1xEDJg87dQdY7aq"], url: "https://brief-api.herokuapp.com/api/v1/secure/twitter/singin") { (succeeded: Bool, msg: String) -> () in
        }
    }
    
    @IBAction func signInWithFacebookButtonPressed(sender: UIButton) {
        self.view.endEditing(true)
        loadingView.hidden = false
        
        var fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager .logInWithReadPermissions(["email"], handler: { (result, error) -> Void in
            if (error == nil){
                var fbloginresult : FBSDKLoginManagerLoginResult = result
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            }
        })
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            
            var fbAccessToken = FBSDKAccessToken.currentAccessToken()!.tokenString
            println(fbAccessToken)
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! NSDictionary
                    println(result)
                    println(self.dict)
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        self.loadingView.hidden = true
                    }
                }
            })
            
            self.facebookSignIn(["accessToken": fbAccessToken as String], url: "https://brief-api.herokuapp.com/api/v1/secure/facebook/singin") { (succeeded: Bool, msg: String) -> () in
            }
        }
    }
    
    func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: "https://brief-api.herokuapp.com/api/v1/secure/singin")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            println(json!)
            
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
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        self.loadingView.hidden = true
                    }
                }
                else {
                    if (json?.objectForKey("authToken") != nil && json?.objectForKey("emailAddress") != nil) {
                        let authToken = json?.objectForKey("authToken") as! String
                        let emailAddress = json?.objectForKey("emailAddress") as! String
                        
                        NSUserDefaults.standardUserDefaults().setObject(authToken, forKey: "authToken")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        var authTokenStr = NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String
                        
                        println("Authorization token is \(authToken)")
                        
                        //
                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isEditProfile")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        //
                        self.performSegueWithIdentifier("fromSignInToCreateProfile", sender: self)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            () -> Void in
                            self.loadingView.hidden = true
                        }
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
    
    func twitterSignIn(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: "https://brief-api.herokuapp.com/api/v1/secure/twitter/singin")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            println(json)
            
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
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        self.loadingView.hidden = true
                    }
                }
                else {
                    if (json?.objectForKey("authToken") != nil) {
                        if json?.objectForKey("emailAddress") == nil {
                            
                            ///
                            var inputTextFieldEmail: UITextField?
                            var inputTextFieldPassword: UITextField?
                            
                            //Create the AlertController
                            let actionSheetController: UIAlertController = UIAlertController(title: "Thank you", message: "Please enter your email and password to complete the sign in with Twitter", preferredStyle: .Alert)
                            
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
                            }
                            actionSheetController.addAction(cancelAction)
                            //Create and an option action
                            let nextAction: UIAlertAction = UIAlertAction(title: "Save", style: .Default) { action -> Void in
                                //Do some other stuff
                                
                                if (inputTextFieldEmail!.text != "" && inputTextFieldPassword!.text != "") {
                                    self.setCredentials(["password": inputTextFieldEmail!.text, "emailAddress": inputTextFieldPassword!.text], url: "https://brief-api.herokuapp.com/api/v1/secure/credentials") { (succeeded: Bool, msg: String) -> () in
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
                        else {
                            let authToken = json?.objectForKey("authToken") as! String
                            
                            NSUserDefaults.standardUserDefaults().setObject(authToken, forKey: "authToken")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            var authTokenStr = NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String
                            
                            println("Authorization token is \(authToken)")
                            //
                            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isEditProfile")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            //
                            self.performSegueWithIdentifier("fromSignInToCreateProfile", sender: self)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                () -> Void in
                                self.loadingView.hidden = true
                            }
                        }
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
            
            println(json)
            
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
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        self.loadingView.hidden = true
                    }
                }
                else {
                    if (json?.objectForKey("authToken") != nil) {
                        let authToken = json?.objectForKey("authToken") as! String
                        
                        NSUserDefaults.standardUserDefaults().setObject(authToken, forKey: "authToken")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        var authTokenStr = NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String
                        
                        println("2 Authorization token is \(authToken)")
                        //
                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isEditProfile")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        //
                        self.performSegueWithIdentifier("fromSignInToCreateProfile", sender: self)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            () -> Void in
                            self.loadingView.hidden = true
                        }
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
    
    func facebookSignIn(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: "https://brief-api.herokuapp.com/api/v1/secure/facebook/singin")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            println(json)
            
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
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        self.loadingView.hidden = true
                    }
                }
                else {
                    if (json?.objectForKey("authToken") != nil) {
                        if json?.objectForKey("emailAddress") == nil {
                            
                            ///
                            var inputTextFieldEmail: UITextField?
                            var inputTextFieldPassword: UITextField?
                            
                            //Create the AlertController
                            let actionSheetController: UIAlertController = UIAlertController(title: "Thank you", message: "Please enter your email and password to complete the sign in with Twitter", preferredStyle: .Alert)
                            
                            
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
                            }
                            actionSheetController.addAction(cancelAction)
                            //Create and an option action
                            let nextAction: UIAlertAction = UIAlertAction(title: "Save", style: .Default) { action -> Void in
                                //Do some other stuff
                                
                                if (inputTextFieldEmail!.text != "" && inputTextFieldPassword!.text != "") {
                                    self.setCredentials(["password": inputTextFieldPassword!.text, "emailAddress": inputTextFieldEmail!.text], url: "https://brief-api.herokuapp.com/api/v1/secure/credentials") { (succeeded: Bool, msg: String) -> () in
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
                        else {
                            let authToken = json?.objectForKey("authToken") as! String
                            
                            NSUserDefaults.standardUserDefaults().setObject(authToken, forKey: "authToken")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            var authTokenStr = NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String
                            
                            println("Authorization token is \(authToken)")
                            //
                            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isEditProfile")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            //
                            self.performSegueWithIdentifier("fromSignInToCreateProfile", sender: self)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                () -> Void in
                                self.loadingView.hidden = true
                            }
                        }
                    }
                }
            }
            
            var msg = "No message"
            
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