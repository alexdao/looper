//
//  ViewController.swift
//  sxsw
//
//  Created by Alex on 3/14/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import PubNub
import HTPressableButton
import SDWebImage
import NVActivityIndicatorView
import SnapKit

class ViewController: UIViewController, PNObjectEventListener {
    
    var client : PubNub!
    var config : PNConfiguration!
    
    var playState = false
    
    let label = UILabel()
    let colors = Colors()
    
    let imageView = UIImageView()
    
    let button = UIButton()
    
    var activityIndicator: NVActivityIndicatorView!
    
    var views: [UIView] = []
    var urls: [String] = []
    var counter = 0
    
    struct Rect {
        var left: CGFloat = 0
        var right: CGFloat = 0
        var top: CGFloat = 0
        var bottom: CGFloat = 0
        var url = ""
    }
    

    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        imageView.isHidden = false
        label.isHidden = true
        let url = URL(string: "https://dd9fae67.ngrok.io/predictions.png")
        let data = try? Data(contentsOf: url!)
        imageView.image = UIImage(data: data!)
        urls = []
        views = []
        counter = 0
        if let data = message.data.message as? String {
            let rects = data.components(separatedBy: "|")
            for rect in rects {
                let data = rect.components(separatedBy: ",")
                if data.count > 1 {
                    print(data)
                    let left = Float(data[0])
                    let right = Float(data[1])
                    let top = Float(data[2])
                    let bot = Float(data[3])
                    let type = data[4]
                    let imageWidth = Float(data[6])
                    let imageHeight = Float(data[7])
                    let leftScaled = CGFloat(left!)/CGFloat(imageWidth!)*view.frame.width
                    let rightScaled = CGFloat(right!)/CGFloat(imageWidth!)*view.frame.width
                    let topScaled = CGFloat(top!)/CGFloat(imageHeight!)*view.frame.height
                    let botScaled = CGFloat(bot!)/CGFloat(imageHeight!)*view.frame.height
                    let newRect = Rect(left: leftScaled, right: rightScaled, top: topScaled, bottom: botScaled, url: "http://www." + type + ".com")
                    generateTouchView(rect: newRect)
                }
            }
        }
        activityIndicator.stopAnimating()
    }
    
    func generateTouchView(rect: Rect) {
        let touchView = UIView(frame: CGRect(x: CGFloat(rect.left), y: CGFloat(rect.top), width: CGFloat(rect.right - rect.left), height: CGFloat(rect.bottom - rect.top)))
        view.addSubview(touchView)
        let touchHandler = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        touchView.addGestureRecognizer(touchHandler)
        touchView.tag = counter
        counter += 1
        urls.append(rect.url)
        views.append(touchView)
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        UIApplication.shared.openURL(URL(string: urls[(sender.view?.tag)!])!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.edges.equalTo(view)
        }
        
        view.backgroundColor = UIColor.clear
        let backgroundLayer = colors.gl
        backgroundLayer?.frame = view.frame
        view.layer.insertSublayer(backgroundLayer!, at: 0)
        
        config = PNConfiguration(publishKey: "pub-c-f89964b0-40f6-4ead-9864-15eb2add8af7", subscribeKey: "sub-c-d4b8b206-08fa-11e7-b95c-0619f8945a4f")
        client = PubNub.clientWithConfiguration(config)
        client.subscribeToChannels(["data"], withPresence: false)
        client.addListener(self)
        
        
        let xCenter = view.center.x
        let yCenter = view.center.y
        
        let frame = CGRect(x: xCenter - 75, y: yCenter - 160, width: 150, height: 150)
        activityIndicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotatePulse, color: UIColor.white, padding: CGFloat(0))
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.activityIndicator.pauseAnimating()
        }
        
        let circularButton = UIButton(frame: frame)
        view.addSubview(circularButton)
        circularButton.addTarget(self, action: #selector(getImage), for: .touchUpInside)
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(view).offset(25)
            make.centerX.equalTo(view)
        }
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Touch to Capture"
        
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(50)
            make.centerX.equalTo(label.snp.centerX)
        }
        
        button.setImage(UIImage(named: "play"), for: .normal)
        
        button.addTarget(self, action: #selector(pausePlayVideo), for: .touchUpInside)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        view.addGestureRecognizer(swipe)
    }
    
    func pausePlayVideo() {
        if(playState) {
            button.setImage(UIImage(named: "pause"), for: .normal)
            playState = false
        } else {
            button.setImage(UIImage(named: "play"), for: .normal)
            playState = true
        }
        client.publish("space", toChannel: "capture", compressed: false, withCompletion: nil)
    }
    
    func swiped(_ gesture: UIGestureRecognizer) {
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.activityIndicator.pauseAnimating()
        }
        for view in views {
            view.removeFromSuperview()
        }
        imageView.isHidden = true
        label.isHidden = false
    }

    func getImage() {
        client.publish("capture", toChannel: "capture", compressed: false, withCompletion: nil)
        activityIndicator.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

