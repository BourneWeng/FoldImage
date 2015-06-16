//
//  PageView.swift
//  ReverseImage
//
//  Created by BourneWeng on 15/6/15.
//  Copyright (c) 2015年 Bourne. All rights reserved.
//

import UIKit

//滑动时候的方向
enum PanDirection {
    case right
    case left
    case up
    case down
}

class PageView: UIView {

    var image: UIImage! {
        didSet {
            addImageView()
            addGestureRecognizer()
        }
    }
    
    var imageView: UIImageView!
    var page1: UIImageView!
    var page2: UIImageView!
    
    var initialLocation: CGPoint!
    var isFirstChange = true
    var direction = PanDirection.right
    
    //添加最开始的imageView,用于占位
    func addImageView() {
        self.imageView = UIImageView(frame: self.bounds)
        self.imageView.image = self.image
        self.addSubview(self.imageView)
    }
    
    
    //添加手势
    func addGestureRecognizer() {
        //滑动手势
        let pan = UIPanGestureRecognizer(target: self, action: Selector("pan:"))
        self.addGestureRecognizer(pan)
    }
    
    
    //滑动手势的处理
    func pan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(self)
        
        switch recognizer.state {
        case .Began:
            self.initialLocation = location
        case .Changed:
            if isFirstChange {
                self.isFirstChange = false
                self.direction = getDirection(location)
                dividePages()
            } else {
                if CGRectContainsPoint(self.bounds, location) {
                    handelPan(location)
                } else {
                    recognizer.enabled = false
                }
              }
        default:
            recognizer.enabled = true
            panEnd()
        }
    }
    
    //根据手势的方向划分不同的pages
    func dividePages() {
        //删除所有子视图
        for view in self.subviews {
            view.removeFromSuperview()
        }

        var horizontal:Bool
        var width: CGFloat
        var height: CGFloat
        var anchorPoint1: CGPoint
        var anchorPoint2: CGPoint
        
        switch self.direction {
        case .right, .left:
            horizontal = false
            width = CGRectGetMidX(self.bounds)
            height = CGRectGetHeight(self.bounds)
            anchorPoint1 = CGPointMake(1.0, 0.5)
            anchorPoint2 = CGPointMake(0.0, 0.5)
            
        case .up, .down:
            horizontal = true
            width = CGRectGetWidth(self.bounds)
            height = CGRectGetMidY(self.bounds)
            anchorPoint1 = CGPointMake(0.5, 1.0)
            anchorPoint2 = CGPointMake(0.5, 0.0)
            
        }
        
        self.page1 = UIImageView(image: cutImage(horizontal, index: 0))
        self.page1.bounds = CGRectMake(0, 0, width, height)
        self.page1.layer.transform = setTransform3D()
        self.page1.layer.anchorPoint = anchorPoint1
        self.page1.layer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        self.addSubview(self.page1)
        
        self.page2 = UIImageView(image: cutImage(horizontal, index: 1))
        self.page2.bounds = CGRectMake(0, 0, width, height)
        self.page2.layer.transform = setTransform3D()
        self.page2.layer.anchorPoint = anchorPoint2
        self.page2.layer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        self.addSubview(self.page2)
    }
    
    //处理各个方向的手势
    func handelPan(location: CGPoint) {
        var percent: CGFloat
        var propertyName: String
        var page: UIImageView
        
        
        switch self.direction {
        case .right:
            //注意：由于“POP”的kPOPLayerRotationY存在Bug，大于90度就会出错，所以这里*0.5，最大90度旋转
            percent = 0.5 * (location.x - initialLocation.x) / (CGRectGetWidth(self.bounds) - self.initialLocation.x)
            propertyName = kPOPLayerRotationY
            page = self.page1
            
        case .left:
            //注意：由于“POP”的kPOPLayerRotationY存在Bug，大于90度就会出错，所以这里*0.5，最大90度旋转
            percent = 0.5 * -(self.initialLocation.x - location.x) / self.initialLocation.x
            propertyName = kPOPLayerRotationY
            page = self.page2
            
        case .up:
            percent = (self.initialLocation.y - location.y) / self.initialLocation.y
            propertyName = kPOPLayerRotationX
            page = self.page2
            
        case .down:
            percent = -(location.y - initialLocation.y) / (CGRectGetHeight(self.bounds) - self.initialLocation.y)
            propertyName = kPOPLayerRotationX
            page = self.page1
            
        }
        
        
        self.bringSubviewToFront(page)
        //popAnimation的使用
        let rotationAnimation = POPBasicAnimation(propertyNamed: propertyName)
        rotationAnimation.duration = 0.01
        rotationAnimation.toValue = CGFloat(M_PI) * percent
        
        page.layer.pop_addAnimation(rotationAnimation, forKey: "rotate")
        
    }
    
    
    //手势结束时的处理方法
    func panEnd() {
        var propertyName: String
        var page: UIImageView
        isFirstChange = true
        
        switch self.direction {
        case .right:
            propertyName = kPOPLayerRotationY
            page = self.page1
            
        case .left:
            propertyName = kPOPLayerRotationY
            page = self.page2
            
        case .up:
            propertyName = kPOPLayerRotationX
            page = self.page2
            
        case .down:
            propertyName = kPOPLayerRotationX
            page = self.page1
            
        }
        
        let recoverAnimation = POPSpringAnimation(propertyNamed: propertyName)
        recoverAnimation.springBounciness = 25.0 //弹簧反弹力度
        recoverAnimation.dynamicsMass = 2.0
        recoverAnimation.dynamicsTension = 200
        recoverAnimation.toValue = 0
        page.layer.pop_addAnimation(recoverAnimation, forKey: "recover")
    }

    
//一些用到的工具方法
    //判断手势方向
    func getDirection(location: CGPoint) -> PanDirection {
        let dx = location.x - self.initialLocation.x
        let dy = location.y - self.initialLocation.y
        
        if abs(dx) > abs(dy) {    //1.水平方向
            if dx < 0 { //向左
                return .left
            } else {    //向右
                return .right
            }
        } else {        //2.竖直方向
            if dy < 0 { //向上
                return .up
            } else {    //向下
                return .down
            }
        }
    }
    
    //裁剪图片
    func cutImage(horizontal: Bool, index: Int) -> UIImage {
        //计算每个块的位置
        let width  = horizontal ? self.image.size.width : (self.image.size.height / 2.0)
        let height = horizontal ? (self.image.size.height / 2.0) : self.image.size.height
        let X = horizontal ? 0.0 : (CGFloat(index) * width)
        let Y = horizontal ? (CGFloat(index) * height) : 0.0
        
        let imageRef = CGImageCreateWithImageInRect(self.image.CGImage, CGRectMake(X, Y, width, height))
        var image = UIImage(CGImage: imageRef)
        
        return image!
    }
    
    //景深效果
    func setTransform3D() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = CGFloat( 2.5 / -2000 )
        
        return transform
    }
}
