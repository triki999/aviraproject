//
//  StoryWebviewViewModel.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa

private let token = Lifetime.Token()
public var lifetime: Lifetime {
    return Lifetime(token)
}

class StoryWebviewViewModel
{
    let model = StorieModel.instance
    
    func changeStoryStatus(_ dbStory:DBStory,state:DBStory.StoryState) -> DBStory.StoryState
    {
        return model.changeStoryStatus(dbStory,state:state)
    }
}
