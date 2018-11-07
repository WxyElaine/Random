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
    }
}
