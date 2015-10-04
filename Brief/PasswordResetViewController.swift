import UIKit

class PasswordResetViewController: UIViewController {

    @IBOutlet weak var briefLogo: UIImageView!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var emailBg: UIImageView!
    @IBOutlet weak var letterImage: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ResetPasswordButtonPressed(sender: UIButton) {
        
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
}
