import UIKit

class searchingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ///Setting up navigation bar
        var logo = UIImage(named: "brief-logo-top.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
