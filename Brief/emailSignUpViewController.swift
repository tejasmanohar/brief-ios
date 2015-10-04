import UIKit

class emailSignUpViewController: UIViewController {
    
    @IBOutlet weak var briefLogo: UIImageView!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var emailAndPasswordBg: UIImageView!
    @IBOutlet weak var letterImage: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var greyLine: UIImageView!
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var loadingView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createLoadingView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createLoadingView () {
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.view.addSubview(loadingView)
        
        var messageView = UIView(frame: CGRectMake((UIScreen.mainScreen().bounds.size.width - 200)/2, (UIScreen.mainScreen().bounds.size.height - 100)/2, 200, 100))
        messageView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        messageView.layer.cornerRadius = 6
        loadingView.addSubview(messageView)
        
        var messageLabel = UILabel(frame: CGRectMake((messageView.frame.size.width - 120)/2, 15, 120, 22))
        messageLabel.text = "Signing Up..."
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
    
    @IBAction func backgroundTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func swipeRight(sender: UISwipeGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
        self.view.endEditing(true)
        self.loadingView.hidden = false
        
        if self.emailTextField.text != "" && self.passwordTextField.text != "" {
            self.post(["password": self.passwordTextField.text, "emailAddress": self.emailTextField.text], url: "https://brief-api.herokuapp.com/api/v1/secure/candidate/singup") { (succeeded: Bool, msg: String) -> () in
            }
        }
        else {
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = "Please enter both email and pasword to the fields above."
            alert.addButtonWithTitle("Ok")
            alert.show()
            
            dispatch_async(dispatch_get_main_queue()) {
                () -> Void in
                self.loadingView.hidden = true
            }

        }
    }
    
    func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: "https://brief-api.herokuapp.com/api/v1/secure/candidate/singup")!)
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
                        self.performSegueWithIdentifier("fromSignUpToCreate", sender: self)
                        
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
