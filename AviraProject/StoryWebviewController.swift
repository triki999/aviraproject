//
//  StoryWebviewController.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import Foundation
import UIKit

class StoryWebviewController : UIViewController
{
    
    var dbStoryData:DBStory!
    let modelView = StoryWebviewViewModel()
    @IBOutlet weak var btnSaveToReadLater: UIBarButtonItem!
    @IBOutlet weak var lbURL: UILabel!
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if dbStoryData.state != DBStory.StoryState.readLater
        {
            let state = modelView.changeStoryStatus(dbStoryData, state: .read)
            changeTintBaseOnState(state)
        }else {
            changeTintBaseOnState(dbStoryData.state)
        }
        
        navigationItem.title = dbStoryData.title
        
        
    }
    
  
    @IBAction func saveToReadLater(_ sender: Any)
    {
        
        let state:DBStory.StoryState!
        if dbStoryData.state == DBStory.StoryState.readLater
        {
            state = modelView.changeStoryStatus(dbStoryData, state: .read)
        }else{
            state = modelView.changeStoryStatus(dbStoryData, state: .readLater)
        }
        
        changeTintBaseOnState(state)
        
    }
    
    private func changeTintBaseOnState(_ state:DBStory.StoryState)
    {
        switch state {
        case .readLater:
            btnSaveToReadLater.tintColor = UIColor.gray
            break;
        default:
            btnSaveToReadLater.tintColor = UIColor.blue
            break;

        }
    }
    
}
