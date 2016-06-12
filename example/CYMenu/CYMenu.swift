//
//  CYMenu.swift
//  CYMenu
//
//  Created by Cairo on 16/6/6.
//  Copyright © 2016年 Cairo. All rights reserved.
//

import UIKit

enum status {
    case Hide
    case Show
    case ShowingAnimate
    case HidingAnimate
}

enum showStyle{
    case Spring
    case All
}

enum hideStyle{
    case All
    case Spring
}

enum direction{
    case Up
    case Down
}

enum Position{
    case Left
    case Right
}

class CYMenuItem: UIView {
    var itemSize : CGFloat
    var backgroundLayer : CALayer
    var titleView : UILabel?
    var backgroundView : UIView
    var titleViewWidth : CGFloat = 100{
        didSet{
            if let view = self.titleView{
                let originX  = self.titlePosition == .Right ? self.frame.origin.x : self.frame.origin.x - self.titleViewWidth - self.titleGap
                self.frame = CGRectMake(originX, self.frame.origin.y, self.itemSize + self.titleViewWidth + self.titleGap, self.itemSize)
            }
        }
    }
    var titleGap : CGFloat = 10{
        didSet{
            if let view = self.titleView{
                let originX  = self.titlePosition == .Right ? self.frame.origin.x : self.frame.origin.x - self.titleViewWidth - self.titleGap
                self.frame = CGRectMake(originX, self.frame.origin.y, self.itemSize + self.titleViewWidth + self.titleGap, self.itemSize)
            }
        }
    }
    var titlePosition : Position = Position.Right{
        didSet{
            if let view = self.titleView{
                let originX = self.titlePosition == .Right ? self.itemSize + self.titleGap : 0
                view.frame = CGRectMake(originX,0,self.titleViewWidth,self.itemSize)
                self.titleView?.textAlignment = self.titlePosition == .Right ? .Left : .Right
            }
            self.setAutoLayout()
        }
    }
    var titleColor : UIColor = UIColor.blackColor(){
        didSet{
            if let view = self.titleView{
                view.textColor = titleColor
            }
        }
    }
    var title : String?{
        didSet{
            if let view = self.titleView{
                titleView?.text = self.title
            }
            else{
                let originX  = self.titlePosition == .Right ? self.frame.origin.x : self.frame.origin.x - self.titleViewWidth
                self.frame = CGRectMake(originX, self.frame.origin.y, self.itemSize + self.titleViewWidth, self.itemSize)
                self.titleView = UILabel(frame: CGRectZero)
                self.titleView!.translatesAutoresizingMaskIntoConstraints = false
                self.titleView!.text = self.title
                self.titleView?.textAlignment = self.titlePosition == .Right ? .Left : .Right
                self.titleView?.textColor = self.titleColor
                self.addSubview(titleView!)
                self.setAutoLayout()
            }
        }
    }
    var imageLayer : CALayer?{
        didSet{
            if let leyer = imageLayer{
                leyer.removeFromSuperlayer()
            }
            self.backgroundView.layer.addSublayer(self.imageLayer!)
        }
    }
    override init(frame: CGRect) {
        self.backgroundView = UIView(frame: CGRectZero)
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundLayer = backgroundView.layer
        self.itemSize = frame.width
        super.init(frame: frame)
        self.addSubview(backgroundView)
        self.setAutoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAutoLayout(){
        self.removeConstraints(self.constraints)
        let backgroundPosition : NSLayoutAttribute = self.titlePosition == .Right ? .Left : .Right
        let titlePosition : NSLayoutAttribute = self.titlePosition == .Right ? .Right : .Left
        
        self.addConstraint(NSLayoutConstraint(item: self.backgroundView, attribute: backgroundPosition, relatedBy: .Equal, toItem: self, attribute: backgroundPosition, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.backgroundView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.backgroundView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: self.itemSize))
        self.addConstraint(NSLayoutConstraint(item: self.backgroundView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: self.itemSize))
        
        if let view =  self.titleView{
            self.addConstraint(NSLayoutConstraint(item: view, attribute:titlePosition , relatedBy: .Equal, toItem: self, attribute: titlePosition, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: view, attribute:.Top , relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: self.titleViewWidth))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: self.itemSize))
        }
    }
}

class CYMenu: UIView {
    var menuShowStyle : showStyle = .Spring
    var menuHideStyle : hideStyle = .Spring
    var numberOfItems : Int = 0
    var itemSize :CGFloat = 65
    var itemSpace : CGFloat = 15
    var originPoint : CGPoint = CGPointMake(0,0)
    var originView : CYMenuItem
    var itemArray : [CYMenuItem] = []
    var menuStatus : status
    var fullFrame : CGRect = CGRectZero
    var smallFrame : CGRect = CGRectZero
    var callBackWithIndex : (Int) -> Void = {_ in }
    var showDirection : direction = direction.Down
    var titleViewWidth : CGFloat = 100{
        didSet{
            self.setFullFrame()
            self.setAutoLayout()
        }
    }
    var menuColor : UIColor = UIColor(red: 67/255, green: 152/255, blue: 151/255, alpha: 1){
        didSet{
            for item in self.itemArray{
                item.backgroundLayer.backgroundColor = self.menuColor.CGColor
            }
        }
    }
    
    var menuColors : [UIColor] = []{
        didSet{
            for (index,color) in self.menuColors.enumerate(){
                self.itemArray[index].backgroundLayer.backgroundColor = color.CGColor
            }
        }
    }
    var titleGap : CGFloat = 10{
        didSet{
            for item in self.itemArray{
                item.titleGap = titleGap
            }
            self.setFullFrame()
            self.setAutoLayout()
        }
    }
    var titleColor : UIColor = UIColor.blackColor(){
        didSet{
            for item in self.itemArray{
                item.titleColor = titleColor
            }
        }
    }
    var menuIcons : [String]?{
        didSet{
            for(index,name) in (menuIcons?.enumerate())!{
                let image = UIImage(named: name)
                let layer = CALayer()
                layer.frame = CGRectMake(10, 10, self.itemSize - 20, self.itemSize - 20)
                layer.contents = image?.CGImage
                self.itemArray[index].imageLayer = layer
            }
        }
    }
    var menuTitles : [String]?{
        didSet{
            self.setFullFrame()
            self.didUseTitle = true
            self.setupTitle()
            self.setAutoLayout()
        }
    }
    var titlePosition : Position = Position.Right{
        didSet{
            if self.menuTitles != nil{
                self.setFullFrame()
                self.setAutoLayout()
            }
            for item in self.itemArray{
                item.titlePosition = self.titlePosition
            }
            
        }
    }
    var hideOriginView : Bool = false{
        didSet{
            self.originView.hidden = hideOriginView
        }
    }
    private var didUseTitle : Bool = false
    private var animatingItem : CYMenuItem?{
        didSet{
            animatingIndex = self.itemArray.indexOf(self.animatingItem!)!
        }
    }
    private var displayLink : CADisplayLink?
    private var initalVelocity:CGFloat = 0
    private var animatingIndex : Int = 0
    
    init(NumberOfItems : Int , ItemSize : CGFloat , ItemSpace : CGFloat , OriginPoint : CGPoint , ShowDirection : direction) {
        self.numberOfItems = NumberOfItems
        self.itemSize = ItemSize
        self.originPoint = OriginPoint
        self.itemSpace = ItemSpace
        self.originView = CYMenuItem(frame: CGRectMake(0 , 0 , itemSize , itemSize))
        self.originView.backgroundColor = UIColor.clearColor()
        self.originView.layer.backgroundColor = self.menuColor.CGColor
        self.originView.layer.cornerRadius = self.originView.bounds.height / 2
        self.originView.translatesAutoresizingMaskIntoConstraints = false
        self.menuStatus = .Hide
        self.showDirection = ShowDirection
        self.smallFrame = CGRectMake(originPoint.x - itemSize / 2,originPoint.y - itemSize / 2 , ItemSize,ItemSize)
        super.init(frame: self.smallFrame)
        self.setFullFrame()
        let mainRecognizer = UITapGestureRecognizer(target: self, action: #selector(CYMenu.didTapOriginView))
        self.originView.addGestureRecognizer(mainRecognizer)
        for i in (0...numberOfItems - 1){
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CYMenu.didTapItem))
            let item = createMenuItem()
            item.addGestureRecognizer(tapRecognizer)
            self.itemArray.append(item)
            self.addSubview(item)
        }
        self.addSubview(self.originView)
        setAutoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAutoLayout(){
        removeConstraints()
        let position  : NSLayoutAttribute = self.titlePosition == .Right ? .Left : .Right
        let originViewPosition : NSLayoutAttribute = self.showDirection == .Down ? .Top : .Bottom
        let positionFactor : CGFloat  = self.showDirection == .Down ? 1 : -1
        self.addConstraint(NSLayoutConstraint(item: self.originView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: self.itemSize))
        self.addConstraint(NSLayoutConstraint(item: self.originView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: self.itemSize))
        self.addConstraint(NSLayoutConstraint(item: self.originView, attribute: position, relatedBy: .Equal, toItem: self, attribute: position, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.originView, attribute: originViewPosition, relatedBy: .Equal, toItem: self, attribute: originViewPosition, multiplier: 1, constant: 0))
        for i in (0...numberOfItems - 1){
            self.addConstraint(NSLayoutConstraint(item: self.itemArray[i], attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item:  self.itemArray[i], attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item:  self.itemArray[i], attribute: originViewPosition, relatedBy: .Equal, toItem: self , attribute: originViewPosition, multiplier:1 , constant: positionFactor *  CGFloat(i + 1) * (self.itemSize + self.itemSpace) ))
            self.addConstraint(NSLayoutConstraint(item:  self.itemArray[i], attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute , multiplier: 0, constant: self.itemSize))
        }
    }
    
    func removeConstraints(){
        self.removeConstraints(self.constraints)
    }
    
    func didTapOriginView(){
        switch menuStatus {
        case .Show:
            startHideAnimate()
        case .Hide:
            startShowAnimate()
        default:
            return
        }
    }
    
    func didTapItem(sender : UIGestureRecognizer){
        if self.menuStatus == .Show{
            self.callBackWithIndex(self.itemArray.indexOf(sender.view! as! CYMenuItem)!)
            self.startHideAnimate()
        }
    }
    
    private func startShowAnimate(){
        prepareForShowAnimate()
        switch menuShowStyle {
        case .Spring:
            executeSpringShowAnimate()
        case .All:
            executeAllShowAnimate()
        }
    }
    
    private func startHideAnimate(){
        prepareForHideAnimate()
        switch menuHideStyle {
        case .All:
            executeAllHideAnimate()
        case .Spring:
            executeSpringHideAnimate()
        }
    }

    private func prepareForShowAnimate(){
        self.frame = fullFrame
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.menuStatus = .ShowingAnimate
        self.animatingItem = itemArray[0]
        self.initalVelocity = 0
    }
    
    private func prepareForHideAnimate(){
        self.animatingItem = itemArray[numberOfItems - 1]
        self.menuStatus = .HidingAnimate
        self.initalVelocity = self.showDirection == .Down ? -8 : 8
    }
    
    private func executeAllShowAnimate(){
        let fromValue = self.showDirection == .Down ? self.itemSize / 2 : self.fullFrame.height - self.itemSize / 2
        for item in itemArray{
            let positionAnimation = CASpringAnimation()
            positionAnimation.keyPath = "position.y"
            positionAnimation.fromValue = fromValue
            positionAnimation.toValue = item.layer.position.y
            positionAnimation.mass = 1
            positionAnimation.stiffness = 70
            positionAnimation.damping = 8
            positionAnimation.initialVelocity = 0
            positionAnimation.duration = positionAnimation.settlingDuration
            item.layer.hidden = false
            item.layer.addAnimation(positionAnimation, forKey: "basic")
            if(self.didUseTitle){
                item.titleView?.layer.opacity = 1
                let opaqueAnimation = CABasicAnimation()
                opaqueAnimation.keyPath = "opacity"
                opaqueAnimation.fromValue = 0
                opaqueAnimation.toValue = 1
                opaqueAnimation.duration = 0.2
                item.titleView?.layer.addAnimation(opaqueAnimation, forKey: "basic")
            }
        }
        self.menuStatus = .Show
    }
    
    private func executeSpringShowAnimate(){
        let fromValue = self.showDirection == .Down ? self.animatingItem!.layer.position.y - self.itemSpace - self.itemSize : self.animatingItem!.layer.position.y + self.itemSpace + self.itemSize
        self.animatingItem?.layer.hidden = false
        let positionAnimation = CASpringAnimation()
        positionAnimation.keyPath = "position.y"
        positionAnimation.fromValue = fromValue
        positionAnimation.toValue = self.animatingItem!.layer.position.y
        positionAnimation.duration = positionAnimation.settlingDuration
        positionAnimation.mass = 1
        positionAnimation.stiffness = 200
        positionAnimation.damping = 7
        positionAnimation.initialVelocity = self.initalVelocity
        
        
        if(self.didUseTitle){
            self.animatingItem?.titleView?.layer.opacity = 1
            let opaqueAnimation = CABasicAnimation()
            opaqueAnimation.keyPath = "opacity"
            opaqueAnimation.fromValue = 0
            opaqueAnimation.toValue = 1
            opaqueAnimation.duration = 0.2
            self.animatingItem!.titleView?.layer.addAnimation(opaqueAnimation, forKey: "basic")
        }
        
        if(self.animatingIndex != self.numberOfItems - 1)
        {
            self.displayLink = CADisplayLink(target: self, selector: #selector(CYMenu.trackItemPosition))
            self.displayLink!.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            self.displayLink?.paused = false
        }
        self.animatingItem?.layer.addAnimation(positionAnimation, forKey: "basic")
        if(animatingIndex == numberOfItems - 1){
            self.menuStatus = .Show
        }
    }
    
   private func executeAllHideAnimate(){
        let toValue = self.showDirection == .Down ? itemSize / 2 : self.fullFrame.height - itemSize / 2
        self.displayLink = CADisplayLink(target: self, selector: #selector(CYMenu.trackItemPosition))
        self.displayLink!.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.displayLink!.paused = false
        for (index,item) in self.itemArray.enumerate(){
            let positionAnimation = CASpringAnimation()
            positionAnimation.keyPath = "position.y"
            positionAnimation.fromValue = item.layer.position.y
            positionAnimation.toValue = toValue
            positionAnimation.mass = 5
            positionAnimation.stiffness = 400
            positionAnimation.damping = 1000
            positionAnimation.initialVelocity = 0
            positionAnimation.duration = positionAnimation.settlingDuration
            item.layer.addAnimation(positionAnimation, forKey: "basic")
            if(self.didUseTitle){
                item.titleView?.layer.opacity = 0
                let alphaAnimate = CABasicAnimation()
                alphaAnimate.keyPath = "opacity"
                alphaAnimate.fromValue = 1
                alphaAnimate.toValue = 0
                alphaAnimate.duration = 0.2
                item.titleView?.layer.addAnimation(alphaAnimate, forKey: "basic")
            }
        }
    }
    
    private func executeSpringHideAnimate(){
        let toValue = self.showDirection == .Down ? (animatingItem?.layer.position.y)! - self.itemSize - self.itemSpace : (animatingItem?.layer.position.y)! + self.itemSize + self.itemSpace
        let positionAnimation = CASpringAnimation()
        positionAnimation.keyPath = "position.y"
        positionAnimation.fromValue = animatingItem?.layer.position.y
        positionAnimation.toValue = toValue
        positionAnimation.mass = 1
        positionAnimation.stiffness = 200
        if(self.animatingIndex == 0 ){
            positionAnimation.damping = 1000
        }
        else{
            positionAnimation.damping = 7
        }
        positionAnimation.initialVelocity = self.initalVelocity
        positionAnimation.duration = positionAnimation.settlingDuration
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(CYMenu.trackItemPosition))
        self.displayLink!.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.displayLink?.paused = false
        self.animatingItem?.layer.addAnimation(positionAnimation, forKey: "basic")
        
        if(self.didUseTitle){
            self.animatingItem?.titleView?.layer.opacity = 0
            let opaqueAnimation = CABasicAnimation()
            opaqueAnimation.keyPath = "opacity"
            opaqueAnimation.fromValue = 1
            opaqueAnimation.toValue = 0
            opaqueAnimation.duration = 0.2
            self.animatingItem!.titleView?.layer.addAnimation(opaqueAnimation, forKey: "basic")
        }
    }
    
    func trackItemPosition(){
        if(self.menuStatus == .ShowingAnimate)
        {
            if(self.menuShowStyle == .Spring)
            {
                let currentY = self.animatingItem!.layer.presentationLayer()!.position.y
                let judge = self.showDirection == .Down ? currentY >= animatingItem?.layer.position.y  : currentY <= animatingItem?.layer.position.y
                if(judge){
                    self.displayLink?.paused = true
                    self.displayLink?.invalidate()
                    if(animatingIndex != numberOfItems - 1){
                        self.animatingItem = self.itemArray[self.animatingIndex + 1]
                        self.initalVelocity = 8
                        executeSpringShowAnimate()
                    }
                }
            }
        }
        else if(self.menuStatus == .HidingAnimate){
            if(self.menuHideStyle == .All){
                for item in self.itemArray
                {
                    let judge = self.showDirection == .Down ? item.layer.presentationLayer()?.position.y <= self.itemSize / 2 + 1 : item.layer.presentationLayer()?.position.y >= self.fullFrame.height - self.itemSize / 2 - 1
                    if(judge){
                        item.layer.hidden = true
                    }
                }
                for item in self.itemArray{
                    if(item.layer.hidden == false){
                        return
                    }
                }
                self.displayLink?.paused = true
                self.displayLink?.invalidate()
                self.menuStatus = .Hide
                self.frame = self.smallFrame
            }
            else if(menuHideStyle == .Spring){
                let currentY = (animatingItem?.layer.presentationLayer()!.position.y)!
                let judge = self.showDirection == .Down ? currentY <= (animatingItem?.layer.position.y)! - itemSpace - itemSize + 2 : currentY >= (animatingItem?.layer.position.y)! + itemSpace + itemSize - 2
                if(judge){
                    animatingItem?.layer.hidden = true
                    self.displayLink?.paused = true
                    self.displayLink?.invalidate()
                    if(animatingIndex != 0){
                        self.animatingItem = self.itemArray[animatingIndex - 1]
                        self.initalVelocity = 10
                        executeSpringHideAnimate()
                    }
                    else{
                        self.menuStatus = .Hide
                        self.frame = self.smallFrame
                    }
                }
            }
        }
    }
    
    private func createMenuItem() -> CYMenuItem {
        let menuItem = CYMenuItem(frame:CGRectMake(0,0,itemSize,itemSize) )
        menuItem.backgroundColor = UIColor.clearColor()
        menuItem.backgroundLayer.backgroundColor = menuColor.CGColor
        menuItem.backgroundLayer.cornerRadius = originView.bounds.height / 2
        menuItem.layer.hidden = true
        menuItem.titleGap = self.titleGap
        menuItem.translatesAutoresizingMaskIntoConstraints = false
        return menuItem
    }
    
    private func setupTitle(){
        for(index,title) in menuTitles!.enumerate(){
            self.itemArray[index].title = title as! String
        }
    }
    
    private func setFullFrame(){
        let originY = self.showDirection == .Down ? originPoint.y - self.itemSize / 2 : originPoint.y - self.itemSize / 2 - CGFloat(self.numberOfItems) * (self.itemSize + self.itemSpace)
        if self.menuTitles != nil{
            let originX = self.titlePosition == .Right ? originPoint.x - self.itemSize / 2 : originPoint.x - self.itemSize / 2 - self.titleGap - self.titleViewWidth
            self.fullFrame = CGRectMake(originX,originY, self.itemSize + self.titleGap + self.titleViewWidth , self.itemSize * CGFloat(self.numberOfItems + 1) + self.itemSpace * CGFloat(self.numberOfItems))
        }
        else{
            self.fullFrame = CGRectMake(originPoint.x - self.itemSize / 2,originY, self.itemSize , self.itemSize * CGFloat(self.numberOfItems + 1) + self.itemSpace * CGFloat(self.numberOfItems))
        }
    }
}
