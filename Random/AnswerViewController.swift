//
//  AnswerViewController.swift
//  Random
//
//  Created by Xinyi Wang on 10/27/18.
//  Copyright © 2018 Xinyi Wang. All rights reserved.
//

import UIKit

class AnswerViewController: UIViewController {
    
    public var eventList: Array<String> = []
    
    private var answer: String = ""
    
    // Color Palette
    // Blueish
    // #7bc8f3
    // UIColor(red:0.48, green:0.78, blue:0.95, alpha:1.0)
    // #6bb8f3
    // UIColor(red:0.42, green:0.72, blue:0.95, alpha:1.0)
    // #5ba8f3
    // UIColor(red:0.36, green:0.66, blue:0.95, alpha:1.0)
    // #388de7
    // UIColor(red:0.22, green:0.55, blue:0.91, alpha:1.0)
    // #387dd7
    // UIColor(red:0.22, green:0.49, blue:0.84, alpha:1.0)
    // #386dc7
    // UIColor(red:0.22, green:0.43, blue:0.78, alpha:1.0)
    // #385db7
    // UIColor(red:0.22, green:0.36, blue:0.72, alpha:1.0)
    // #384da7
    // UIColor(red:0.22, green:0.30, blue:0.65, alpha:1.0)
    private var colors: Array<UIColor> = [
        UIColor(red:0.48, green:0.78, blue:0.95, alpha:1.0),
        UIColor(red:0.42, green:0.72, blue:0.95, alpha:1.0),
        UIColor(red:0.36, green:0.66, blue:0.95, alpha:1.0),
        UIColor(red:0.22, green:0.55, blue:0.91, alpha:1.0),
        UIColor(red:0.22, green:0.49, blue:0.84, alpha:1.0),
        UIColor(red:0.22, green:0.43, blue:0.78, alpha:1.0),
        UIColor(red:0.22, green:0.36, blue:0.72, alpha:1.0),
        UIColor(red:0.22, green:0.30, blue:0.65, alpha:1.0)]
    private let NUM_OF_COLORS = 8
    
    @IBOutlet weak var answerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        displayAnswer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func regenerate(_ sender: UIButton) {
        displayAnswer()
    }
    
    @IBAction func okPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToFirst", sender: self)
    }
    
    private func displayAnswer() {
        answer = eventList[Int.random(in: 0 ..< eventList.count)]
        answerLabel.text = answer
        answerLabel.textColor = colors[Int.random(in: 0 ..< NUM_OF_COLORS)]
    }
}
