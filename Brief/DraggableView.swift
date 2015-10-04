//
//  DraggableView.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit

let ACTION_MARGIN: Float = 120      //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
let SCALE_STRENGTH: Float = 4       //%%% how quickly the card shrinks. Higher = slower shrinking
let SCALE_MAX:Float = 0.93          //%%% upper bar for how much the card shrinks. Higher = shrinks less
let ROTATION_MAX: Float = 1         //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
let ROTATION_STRENGTH: Float = 320  //%%% strength of rotation. Higher = weaker rotation
let ROTATION_ANGLE: Float = 3.14/8  //%%% Higher = stronger rotation angle

protocol DraggableViewDelegate {
    func cardSwipedLeft(card: UIView) -> Void
    func cardSwipedRight(card: UIView) -> Void
}

class DraggableView: UIView {
    var delegate: DraggableViewDelegate!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var originPoint: CGPoint!
    var overlayView: OverlayView!
    var information: UILabel!
    var xFromCenter: Float!
    var yFromCenter: Float!
    
    var logoImage: UIImageView!
    var lineOne: UIImageView!
    var lineTwo: UIImageView!
    var locationImage: UIImageView!
    var timeImage: UIImageView!
    var moneyImage: UIImageView!
    var locationLabel: UILabel!
    var timeLabel: UILabel!
    var moneyLabel: UILabel!
    var tagsImage: UIImageView!
    var tagsLabel: UILabel!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupView()
        
        logoImage = UIImageView(frame: CGRectMake((self.frame.size.width - 145)/2, 30, 145, 40))
        logoImage.image = UIImage(named: "DropboxLogo")
        self.addSubview(logoImage)
        
        information = UILabel(frame: CGRectMake(0, 96, self.frame.size.width, 26))
        information.text = "Senior Executive Person"
        information.textAlignment = NSTextAlignment.Center
        information.textColor = UIColor(red: 126.0/255.0, green: 127.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        information.font = UIFont(name: "avenirnext-demibold", size: 19)
        
        lineTwo = UIImageView(frame: CGRectMake((self.frame.size.width - 270)/2, 130, 270, 3))
        lineTwo.image = UIImage(named: "lineC")
        self.addSubview(lineTwo)
        
        logoImage = UIImageView(frame: CGRectMake((self.frame.size.width - 270)/2, 195, 270, 3))
        logoImage.image = UIImage(named: "lineC")
        self.addSubview(logoImage)
        
        locationImage = UIImageView(frame: CGRectMake(self.frame.size.width/2 - 118 + 25, 140, 25, 25))
        locationImage.image = UIImage(named: "locationIcon")
        self.addSubview(locationImage)
        
        timeImage = UIImageView(frame: CGRectMake((self.frame.size.width - 25)/2, 140, 25, 25))
        timeImage.image = UIImage(named: "timeIcon")
        self.addSubview(timeImage)
        
        moneyImage = UIImageView(frame: CGRectMake(self.frame.size.width/2 + 93 - 25, 140, 25, 25))
        moneyImage.image = UIImage(named: "moneyIcon")
        self.addSubview(moneyImage)
        
        locationLabel = UILabel(frame: CGRectMake(0, 86, 110, 17))
        locationLabel.center = locationImage.center
        locationLabel.frame.origin.y += 30
        locationLabel.text = "Berkeley, CA"
        locationLabel.textAlignment = NSTextAlignment.Center
        locationLabel.textColor = UIColor(red: 126.0/255.0, green: 127.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        locationLabel.font = UIFont(name: "avenirnext-demibold", size: 12)
        self.addSubview(locationLabel)
        
        timeLabel = UILabel(frame: CGRectMake(0, 96, 50, 17))
        timeLabel.center = timeImage.center
        timeLabel.frame.origin.y += 30
        timeLabel.text = "5 years"
        timeLabel.textAlignment = NSTextAlignment.Center
        timeLabel.textColor = UIColor(red: 126.0/255.0, green: 127.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        timeLabel.font = UIFont(name: "avenirnext-demibold", size: 12)
        self.addSubview(timeLabel)
        
        moneyLabel = UILabel(frame: CGRectMake(0, 96, 50, 17))
        moneyLabel.center = moneyImage.center
        moneyLabel.frame.origin.y += 30
        moneyLabel.text = "70-90k+"
        moneyLabel.textAlignment = NSTextAlignment.Center
        moneyLabel.textColor = UIColor(red: 126.0/255.0, green: 127.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        moneyLabel.font = UIFont(name: "avenirnext-demibold", size: 12)
        self.addSubview(moneyLabel)
        
//        tagsImage = UIImageView(frame: CGRectMake((self.frame.size.width - 227)/2, 220, 227, 107))
//        tagsImage.image = UIImage(named: "tags")
//        self.addSubview(tagsImage)
        
        //
        tagsLabel = UILabel(frame: CGRectMake((self.frame.size.width - 227)/2, 220, 227, 107))
        tagsLabel.center = tagsLabel.center
        tagsLabel.frame.origin.y -= 10
        tagsLabel.text = "TECHNOLOGY   IOT   SERVERS   CUSTOMERS   MOCKUPS   UI/UX"
        tagsLabel.numberOfLines = 0
        tagsLabel.textAlignment = NSTextAlignment.Left
        tagsLabel.textColor = UIColor(red: 126.0/255.0, green: 127.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        tagsLabel.font = UIFont(name: "avenirnext-demibold", size: 20)
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        var attrString = NSMutableAttributedString(string: tagsLabel.text!)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSRange(location:2,length:4))

        
        tagsLabel.attributedText = attrString
        
        self.addSubview(tagsLabel)
        //

        self.backgroundColor = UIColor.whiteColor()

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "beingDragged:")

        self.addGestureRecognizer(panGestureRecognizer)
        self.addSubview(information)

        overlayView = OverlayView(frame: CGRectMake(self.frame.size.width/2-100, 0, 100, 100))
        overlayView.alpha = 0
        self.addSubview(overlayView)

        xFromCenter = 0
        yFromCenter = 0
    }

    func setupView() -> Void {
        self.layer.cornerRadius = 6;
        self.layer.shadowRadius = 1;
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowOffset = CGSizeMake(1, 1);
    }

    func beingDragged(gestureRecognizer: UIPanGestureRecognizer) -> Void {
        xFromCenter = Float(gestureRecognizer.translationInView(self).x)
        yFromCenter = Float(gestureRecognizer.translationInView(self).y)
        
        switch gestureRecognizer.state {
        case UIGestureRecognizerState.Began:
            self.originPoint = self.center
        case UIGestureRecognizerState.Changed:
            let rotationStrength: Float = min(xFromCenter/ROTATION_STRENGTH, ROTATION_MAX)
            let rotationAngle = ROTATION_ANGLE * rotationStrength
            let scale = max(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX)

            self.center = CGPointMake(self.originPoint.x + CGFloat(xFromCenter), self.originPoint.y + CGFloat(yFromCenter))

            let transform = CGAffineTransformMakeRotation(CGFloat(rotationAngle))
            let scaleTransform = CGAffineTransformScale(transform, CGFloat(scale), CGFloat(scale))
            self.transform = scaleTransform
            self.updateOverlay(CGFloat(xFromCenter))
        case UIGestureRecognizerState.Ended:
            self.afterSwipeAction()
        case UIGestureRecognizerState.Possible:
            fallthrough
        case UIGestureRecognizerState.Cancelled:
            fallthrough
        case UIGestureRecognizerState.Failed:
            fallthrough
        default:
            break
        }
    }

    func updateOverlay(distance: CGFloat) -> Void {
        if distance > 0 {
            overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeRight)
        } else {
            overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeLeft)
        }
        overlayView.alpha = CGFloat(min(fabsf(Float(distance))/100, 0.4))
    }

    func afterSwipeAction() -> Void {
        let floatXFromCenter = Float(xFromCenter)
        if floatXFromCenter > ACTION_MARGIN {
            self.rightAction()
        } else if floatXFromCenter < -ACTION_MARGIN {
            self.leftAction()
        } else {
            UIView.animateWithDuration(0.3, animations: {() -> Void in
                self.center = self.originPoint
                self.transform = CGAffineTransformMakeRotation(0)
                self.overlayView.alpha = 0
            })
        }
    }
    
    func rightAction() -> Void {
        let finishPoint: CGPoint = CGPointMake(500, 2 * CGFloat(yFromCenter) + self.originPoint.y)
        UIView.animateWithDuration(0.3,
            animations: {
                self.center = finishPoint
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedRight(self)
    }

    func leftAction() -> Void {
        let finishPoint: CGPoint = CGPointMake(-500, 2 * CGFloat(yFromCenter) + self.originPoint.y)
        UIView.animateWithDuration(0.3,
            animations: {
                self.center = finishPoint
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedLeft(self)
    }

    func rightClickAction() -> Void {
        let finishPoint = CGPointMake(600, self.center.y)
        UIView.animateWithDuration(0.3,
            animations: {
                self.center = finishPoint
                self.transform = CGAffineTransformMakeRotation(1)
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedRight(self)
    }

    func leftClickAction() -> Void {
        let finishPoint: CGPoint = CGPointMake(-600, self.center.y)
        UIView.animateWithDuration(0.3,
            animations: {
                self.center = finishPoint
                self.transform = CGAffineTransformMakeRotation(1)
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedLeft(self)
    }
}