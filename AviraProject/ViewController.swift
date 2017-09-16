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
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        StorieModel.instance.getStoriesDetailList(type:StorieModel.StoryType.new).startWithResult { (result) in
            switch result{
            case .failure(let error):
                print(error)
                break;
                
            case .success(let val):
                print(val)
                break;
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

