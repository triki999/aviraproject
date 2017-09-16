//
//  StoriesListViewModel.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa

class StoriesListViewModel : NSObject
{
    private let model = StorieModel.instance
    
    var topStoriesListIDS:StoriesList?
    var newStoriesListIDS:StoriesList?
    
    private let token = Lifetime.Token()
    public var lifetime: Lifetime {
        return Lifetime(token)
    }
    
    func getAllStoriesIDS() -> SignalProducer<Bool,WebErrors>
    {
        let returnSignal = model.getAllStoriesIDS()
            .take(during: lifetime)
            .doNext {[unowned self] (newStories,topStories) in
            self.topStoriesListIDS = topStories
            self.newStoriesListIDS = newStories
        }.flatMap(.latest) { (_,_) ->SignalProducer<Bool,WebErrors> in
            SignalProducer(value:true)
        }
        
        return returnSignal
    }
    
    private func getStoryIdFromIndexPath(_ index:IndexPath) -> Int?
    {
        if index.section == 0{
            return topStoriesListIDS?.ids[index.row]
        }
        return newStoriesListIDS?.ids[index.row]
    }
    
    func getStorySignal(index:IndexPath) ->SignalProducer<DBStory, WebErrors>
    {
        guard let storyID = getStoryIdFromIndexPath(index) else {
            return SignalProducer.empty
        }
        
        return model.getStorySignal(storyId:storyID).take(during: lifetime)
        
    }
    
    
}
