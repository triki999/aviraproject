//
//  ViewController.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa











class ViewController: UIViewController {
    
    let mainService = MainService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        
        let signal:SignalProducer<StorieList,WebErrors> = mainService.get(url: "https://hacker-news.firebaseio.com/v0/topstories.json")
        
        signal.startWithResult { (result) in
            switch result{
            case .failure(let er):
                    print(er)
                break
            case .success(let val):
                    print(val)
                    break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

