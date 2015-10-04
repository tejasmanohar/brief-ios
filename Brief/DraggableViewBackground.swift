//
//  DraggableViewBackground.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit

class DraggableViewBackground: UIView, DraggableViewDelegate {
    var titleArray = Array<String>()
    var locationArray = Array<String>()
    var experienceArray = Array<String>()
    var salaryArray = Array<String>()
    var tagsArray = Array<String>()
    var jobIdsArray = Array<Int>()
    
    var cardsCount = 0
    
    var allCards: [DraggableView]!
    
    let MAX_BUFFER_SIZE = 2
    let CARD_HEIGHT: CGFloat = 340
    let CARD_WIDTH: CGFloat = 288
    
    var cardsLoadedIndex: Int!
    var loadedCards: [DraggableView]!
    var menuButton: UIButton!
    var messageButton: UIButton!
    var checkButton: UIButton!
    var infoButton: UIButton!
    var xButton: UIButton!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.layoutSubviews()
        
        if NSUserDefaults.standardUserDefaults().objectForKey("jobsArray") != nil {
            var jobs = NSUserDefaults.standardUserDefaults().objectForKey("jobsArray") as! Array<AnyObject>
            
            if jobs.count > 0 {
//                println(jobs)
                for index in 0...jobs.count-1 {
                    let job = jobs[index] as! Dictionary<String, AnyObject>
                    
//                    println(job)
//                    println(index)
                    
                    let title = job["title"] as! String
                    let city = job["cityName"] as! String
                    let state = job["stateCode"] as! String
                    let country = job["countryCode"] as! String
                    let experience = job["experience"] as! Int
                    let minSalary = job["minSalary"] as! Int
                    let maxSalary = job["maxSalary"] as! Int
                    let companyId = job["companyId"] as! Int
                    let id = job["id"] as! Int
                    var skills = Array<String>()
                    let skillsArray = job["skills"] as! Array<AnyObject>
                    if skillsArray.count > 0 {
                        for index in 0...skillsArray.count-1 {
                            let skillsDict = skillsArray[index] as! Dictionary<String, String>
                            let skill = skillsDict["name"]
                            if skill != "" {
                                skills.append(skill!)
                            }
                        }
                    }
                    //Title
                    titleArray.append(title)
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
                    locationArray.append(location)
                    //Experience
                    var experienceString = ""
                    if experience == 1 {
                        experienceString = "1 year"
                    }
                    else {
                        experienceString = "\(experience) years"
                    }
                    experienceArray.append(experienceString)
                    //Salary
                    var salary = ""
                    salary = "\(minSalary/1000)-\(maxSalary/1000)k+"
                    salaryArray.append(salary)
                    
                    var tags = ""
                    if skills.count > 0 {
                        for index in 0...skills.count-1 {
                            tags = "\(tags)\(skills[index]) "
                        }
                        tags = tags.uppercaseString
                        tagsArray.append(tags)
                    }
                    jobIdsArray.append(id)
                }
            }
            
            self.setupView()
            
            cardsCount = titleArray.count
            
            allCards = []
            loadedCards = []
            cardsLoadedIndex = 0
            self.loadCards()
        }
    }
    
    func setupView() -> Void {
        self.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1)
        
        xButton = UIButton(frame: CGRectMake(self.frame.size.width/2 - 115, self.frame.size.height - 114, 89, 89))
        xButton.setImage(UIImage(named: "cancel"), forState: UIControlState.Normal)
        xButton.addTarget(self, action: "swipeLeft", forControlEvents: UIControlEvents.TouchUpInside)
        
        checkButton = UIButton(frame: CGRectMake(self.frame.size.width/2 + 26, self.frame.size.height - 114, 89, 89))
        checkButton.setImage(UIImage(named: "check"), forState: UIControlState.Normal)
        checkButton.addTarget(self, action: "swipeRight", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(xButton)
        self.addSubview(checkButton)
        
        var imageView : UIImageView
        imageView  = UIImageView(frame:CGRectMake((self.frame.size.width - 144)/2, (self.frame.size.height - 188)/2 - 20, 144, 188));
        imageView.image = UIImage(named:"nothingNew")
        self.addSubview(imageView)
        
    }
    
    func createDraggableViewWithDataAtIndex(index: NSInteger) -> DraggableView {
        var draggableView = DraggableView(frame: CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT)/2 - 20, CARD_WIDTH, CARD_HEIGHT))
        draggableView.information.text = titleArray[index]
        draggableView.locationLabel.text = locationArray[index]
        draggableView.timeLabel.text = experienceArray[index]
        draggableView.moneyLabel.text = salaryArray[index]
        //
        if tagsArray.count > 0 {
            draggableView.tagsLabel.text = tagsArray[index]
        }
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        var attrString = NSMutableAttributedString(string: draggableView.tagsLabel.text!)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        draggableView.tagsLabel.attributedText = attrString
        //
        
        draggableView.delegate = self
        return draggableView
    }
    
    func loadCards() -> Void {
        if titleArray.count > 0 {
            let numLoadedCardsCap = titleArray.count > MAX_BUFFER_SIZE ? MAX_BUFFER_SIZE : titleArray.count
            for var i = 0; i < titleArray.count; i++ {
                var newCard: DraggableView = self.createDraggableViewWithDataAtIndex(i)
                allCards.append(newCard)
                if i < numLoadedCardsCap {
                    loadedCards.append(newCard)
                }
            }
            
            for var i = 0; i < loadedCards.count; i++ {
                if i > 0 {
                    self.insertSubview(loadedCards[i], belowSubview: loadedCards[i - 1])
                } else {
                    self.addSubview(loadedCards[i])
                }
                cardsLoadedIndex = cardsLoadedIndex + 1
            }
        }
        
        makeButtonsGrey()
        
        if jobIdsArray.count > 0 {
            println("The top card ID: \(jobIdsArray[titleArray.count - cardsCount])")
            //Save top card id
            NSUserDefaults.standardUserDefaults().setInteger(jobIdsArray[titleArray.count - cardsCount], forKey: "topCardID")
        }
        else {
            println("Cards are over!")
            NSUserDefaults.standardUserDefaults().setInteger(100000, forKey: "topCardID")
        }
    }
    
    func makeButtonsGrey() {
        if loadedCards.count == 0 {
            xButton.setImage(UIImage(named: "cancelG"), forState: UIControlState.Normal)
            checkButton.setImage(UIImage(named: "checkG"), forState: UIControlState.Normal)
        }
    }
    
    func cardSwipedLeft(card: UIView) -> Void {
        loadedCards.removeAtIndex(0)
        
        makeButtonsGrey()
        
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
        
        cardsCount = cardsCount - 1
        let jobID = jobIdsArray[titleArray.count - cardsCount - 1]
        println("Declined card with ID: \(jobIdsArray[titleArray.count - cardsCount - 1)")
        
        dismissAJob(jobID)
        
        if jobIdsArray.count > 0 {
            if loadedCards.count > 0 {
                println("The top card ID: \(jobIdsArray[titleArray.count - cardsCount])")
                //Save top card id
                NSUserDefaults.standardUserDefaults().setInteger(jobIdsArray[titleArray.count - cardsCount], forKey: "topCardID")
            }
            else {
                println("Cards are over!")
                NSUserDefaults.standardUserDefaults().setInteger(100000, forKey: "topCardID")
            }
        }
    }
    
    func cardSwipedRight(card: UIView) -> Void {
        loadedCards.removeAtIndex(0)
        
        makeButtonsGrey()
        
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
        
        cardsCount = cardsCount - 1
        let jobID = jobIdsArray[titleArray.count - cardsCount - 1]
        println("Accepted card with ID: \(jobIdsArray[titleArray.count - cardsCount - 1)")
        
        applyForJob(jobID)
        
        if jobIdsArray.count > 0 {
            if loadedCards.count > 0 {
                println("The top card ID: \(jobIdsArray[titleArray.count - cardsCount])")
                //Save top card id
                NSUserDefaults.standardUserDefaults().setInteger(jobIdsArray[titleArray.count - cardsCount], forKey: "topCardID")
            }
            else {
                println("Cards are over!")
                NSUserDefaults.standardUserDefaults().setInteger(100000, forKey: "topCardID")
            }
        }
    }
    
    func swipeRight() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        var dragView: DraggableView = loadedCards[0]
        dragView.overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeRight)
        UIView.animateWithDuration(0.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.rightClickAction()
    }
    
    func swipeLeft() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        var dragView: DraggableView = loadedCards[0]
        dragView.overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeLeft)
        UIView.animateWithDuration(0.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.leftClickAction()
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
            println(strData)
            
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
        //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(NSUserDefaults.standardUserDefaults().stringForKey("authToken")! as String, forHTTPHeaderField: "X-Auth-Token")
        
        var session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if((error) != nil) {
                println(error.localizedDescription)
            }
            
            var strData = NSString(data: data, encoding: NSASCIIStringEncoding)
            println(strData)
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? Dictionary <String, AnyObject>
            if json != nil {
                println(json)
            }
        })
        task.resume()
    }
}