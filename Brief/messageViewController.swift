import UIKit
import  Starscream

class messageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WebSocketDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var timer : NSTimer = NSTimer()
    let socket = WebSocket(url: NSURL(scheme: "wss", host: "brief-api.herokuapp.com", path: "/api/v1/conversation/websocket")!)
    var messages = [AnyObject]()
    var loadingView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createLoadingView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        self.navigationItem.title = NSUserDefaults.standardUserDefaults().objectForKey("selectedConversationTitle") as? String
        
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        nav?.titleTextAttributes = [NSFontAttributeName: UIFont(name: "avenirnext-demibold", size: 18)!]
        
        getConversationMessages()
        
        // Do any additional setup after loading the view.
        socket.delegate = self
        socket.connect()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("authorizationMethod"), userInfo: nil, repeats: true)
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
    
    func authorizationMethod() {
        if self.socket.isConnected {
            println("Connected")
            
            var err: NSError?
            var authDict = ["eventType": "AUTHORIZATION", "body": ["authToken" : NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String]]
            var authData = NSJSONSerialization.dataWithJSONObject(authDict, options: nil, error: &err)
            var authString = NSString(data: authData!, encoding: NSUTF8StringEncoding) as! String
            println(authString)
            
            if authData != nil {
                self.socket.writeString(authString)
            }
        }
        else {
            println("Not connected")
        }
    }
    
    @IBAction func sendButtonPressed(sender: UIButton) {
        if messageField.text != "" {
            if self.socket.isConnected {
                var err: NSError?
                var authDict = ["eventType": "MESSAGE", "body": ["conversationId" : "1", "message" : messageField.text]]
                var authData = NSJSONSerialization.dataWithJSONObject(authDict, options: nil, error: &err)
                var authString = NSString(data: authData!, encoding: NSUTF8StringEncoding) as! String
                println(authString)
                
                if authData != nil {
                    self.socket.writeString(authString)
                }
            }
            else {
                println("Not connected")
            }
            
            ///
            messageField.text = ""
        }
        else {
            println("Empty message")
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height
        })
        
        //auto scroll down example
        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = 0
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        var currentMessage = self.messages[indexPath.row] as! Dictionary<String, AnyObject>
        var userID = currentMessage["role"] as! String
        
        let theSubviews = cell.subviews
        for view: AnyObject in theSubviews {
            view.removeFromSuperview()
        }
        
        if userID == "CANDIDATE" {
            //Label
            var label = UILabel(frame: CGRectMake((UIScreen.mainScreen().bounds.width - 16 - 250), 16, 250, 21))
            label.numberOfLines = 0
            label.backgroundColor = UIColor(red: 106.0/255.0, green: 172.0/250.0, blue: 250.0/255.0, alpha: 1.0)
            label.textAlignment = NSTextAlignment.Left
            label.text = currentMessage["message"] as? String
            label.font = UIFont(name: "avenirnext-medium", size: 14)
            label.textColor = UIColor.whiteColor()
            label.sizeToFit()
            label.frame = CGRectMake((UIScreen.mainScreen().bounds.width - 16 - label.frame.size.width), 16, label.frame.size.width, label.frame.size.height)
            //Background
            var view = UIView(frame: CGRectMake(label.frame.origin.x - 8, label.frame.origin.y - 8, label.frame.size.width + 16, label.frame.size.height + 16))
            view.backgroundColor = UIColor(red: 106.0/255.0, green: 172.0/250.0, blue: 250.0/255.0, alpha: 1.0)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 16.0
            //Corner
            var imageView : UIImageView
            imageView  = UIImageView(frame:CGRectMake((UIScreen.mainScreen().bounds.width - 18.5), view.frame.origin.y + view.frame.size.height - 7, 12.5, 7));
            imageView.image = UIImage(named:"userMessageBgCorner")
            
            cell.addSubview(imageView)
            cell.addSubview(view)
            cell.addSubview(label)
        }
        else if userID == "EMPLOYER" {
            //Label
            var label = UILabel(frame: CGRectMake(16, 16, 250, 21))
            label.numberOfLines = 0
            label.backgroundColor = UIColor(red: 236.0/255.0, green: 238.0/250.0, blue: 241.0/255.0, alpha: 1.0)
            label.textAlignment = NSTextAlignment.Left
            label.text = currentMessage["message"] as? String
            label.font = UIFont(name: "avenirnext-medium", size: 14)
            label.textColor = UIColor(red: 126.0/255.0, green: 127.0/255.0, blue: 129.0/255.0, alpha: 1.0)
            label.sizeToFit()
            //Background
            var view = UIView(frame: CGRectMake(label.frame.origin.x - 8, label.frame.origin.y - 8, label.frame.size.width + 16, label.frame.size.height + 16))
            view.backgroundColor = UIColor(red: 236.0/255.0, green: 238.0/250.0, blue: 241.0/255.0, alpha: 1.0)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 16.0
            //Corner
            var imageView : UIImageView
            imageView  = UIImageView(frame:CGRectMake(16 - 10, view.frame.origin.y + view.frame.size.height - 6.5, 13, 6.5));
            imageView.image = UIImage(named:"incomingMessageCorner")
            
            cell.addSubview(imageView)
            cell.addSubview(view)
            cell.addSubview(label)
        }
        
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var currentMessage = self.messages[indexPath.row] as! Dictionary<String, AnyObject>
        var userID = currentMessage["role"] as! String
        
        if userID == "CANDIDATE" {
            var label = UILabel(frame: CGRectMake((UIScreen.mainScreen().bounds.width - 16 - 250), 0, 250, 21))
            label.numberOfLines = 0
            label.textAlignment = NSTextAlignment.Left
            label.text = currentMessage["message"] as? String
            label.sizeToFit()
            
            return label.frame.size.height + 28
        }
        else if userID == "EMPLOYER" {
            var label = UILabel(frame: CGRectMake(16, 0, 250, 21))
            label.numberOfLines = 0
            label.backgroundColor = UIColor(red: 236.0/255.0, green: 238.0/250.0, blue: 241.0/255.0, alpha: 1.0)
            label.textAlignment = NSTextAlignment.Left
            label.text = currentMessage["message"] as? String
            label.sizeToFit()
            
            return label.frame.size.height + 28
        }
        else {
            return 44
        }
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        
        if self.socket.isConnected {
            socket.disconnect()
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // websocketDidConnect is called as soon as the client connects to the server.
    func websocketDidConnect(socket: WebSocket) {
        println("websocket is connected")
    }
    
    // websocketDidDisconnect is called as soon as the client is disconnected from the server.
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        println("websocket is disconnected: \(error!.localizedDescription)")
    }
    
    // websocketDidReceiveMessage is called when the client gets a text frame from the connection.
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        //        println("Answer: \(text)")
        
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            var error: NSError?
            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! Dictionary<String, AnyObject>
            if json["eventType"] as! String == "SUCCESS" {
                println("Authorized")
                
                timer.invalidate()
                
                timer = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: Selector("sendAliveMessage"), userInfo: nil, repeats: true)
            }
            
            if json["eventType"] as! String == "MESSAGE" {
                println(json["body"])
                ///
                self.messages.append(json["body"] as! Dictionary<String, AnyObject>)
                //
                println(json["body"])
                //
                
                self.reloadDataAndScrollDown()
                
                let currentMessage = json["body"] as! Dictionary<String, AnyObject>
                let status = currentMessage["status"] as! String
                let toReadID = currentMessage["id"] as! NSNumber
                if status == "UNREAD" {
                    self.markMessageAsRead(toReadID)
                }
            }
        }
    }
    
    func reloadDataAndScrollDown() {
        self.tableView.reloadData()
        //auto scroll down example
        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        }
    }
    
    // websocketDidReceiveData is called when the client gets a binary frame from the connection.
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        println("got some data: \(data.length)")
    }
    
    func websocketDidReceivePong(socket: WebSocket) {
        println("Got pong!")
    }
    
    func sendAliveMessage() {
        if self.socket.isConnected {
            var err: NSError?
            var authDict = ["eventType": "ALIVE"]
            var authData = NSJSONSerialization.dataWithJSONObject(authDict, options: nil, error: &err)
            var authString = NSString(data: authData!, encoding: NSUTF8StringEncoding) as! String
            println(authString)
            
            if authData != nil {
                self.socket.writeString(authString)
            }
        }
        else {
            println("Not connected")
        }
    }
    
    func getConversationMessages() {
        self.loadingView.hidden = false
        
        var idString = NSUserDefaults.standardUserDefaults().objectForKey("selectedConversation") as! NSNumber

        var jobsURL = NSURL(string: "https://brief-api.herokuapp.com/api/v1/conversations/\(idString)/messages")
        
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
                println("Messages:")
                println(json!)
                if json!.count > 0 {
                    self.messages = json!
                    if self.messages.count > 0 {
                        for index in 0...self.messages.count-1 {
                            let currentMessage = self.messages[index] as! Dictionary<String, AnyObject>
                            let status = currentMessage["status"] as! String
                            let toReadID = currentMessage["id"] as! NSNumber
                            if status == "UNREAD" {
                                self.markMessageAsRead(toReadID)
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        () -> Void in
                        self.reloadDataAndScrollDown()
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                () -> Void in
                self.loadingView.hidden = true
            }
        })
        task.resume()
    }
    
    func markMessageAsRead(messageID : NSNumber) -> () {
        println("Need to mark the \(messageID) as read")
        
        markAsReadMethod(messageID)
    }
    
    func markAsReadMethod(messageID : NSNumber) {
        var jobsURL = NSURL(string: "https://brief-api.herokuapp.com/api/v1/conversations/messages/read/\(messageID)")
        
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
