//
//  StoriesModel.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift

class StorieModel
{
    enum StoryType
    {
        case new, top
    }
    
    public static let  instance:StorieModel = StorieModel()
    
    var topStoriesList:[Story]?
    var newStoriesList:[Story]?

    private init()
    {
        
    }
    
    
    public func clearModel()
    {
        topStoriesList = nil;
        newStoriesList = nil;
    }
    
    public func getAllStories() -> SignalProducer<([Story],[Story]),WebErrors>
    {
    
        
        let newStoriesSignal = getStoriesDetailList(type: .new)
        let topStoriesSignal = getStoriesDetailList(type: .top)
        
        let returnSignal = SignalProducer.combineLatest(newStoriesSignal, topStoriesSignal).doNext {[weak self] (newStories,topStories) in
            self?.newStoriesList = newStories;
            self?.topStoriesList = topStories
        }
        
        return returnSignal;
       
    }
    
    private func fillDBStoryStatus(stories:[Story])
    {
        for story in stories
        {
            let realm = try! Realm()
            let query = "where id == \(story.id)"
            if let _ = realm.objects(DBStory.self).filter(query).first
            {
                
            }else{
                
                let dbStory = DBStory()
                dbStory.update {
                    dbStory.id = story.id;
                    dbStory.state = .unread
                }
                realm.add(dbStory)
   
            }
            
            
            
        }
    }
    
    
    private func getStoriesDetailList(type:StorieModel.StoryType) -> SignalProducer<[Story],WebErrors>
    {
        
        var storyListSignal:SignalProducer<StoriesList,WebErrors>!
        
        switch type
        {
            case .new:
                storyListSignal = HelperServices.getNewStories()
            break;
            
            case .top:
                storyListSignal = HelperServices.getTopStories()
            break;
        }
        
        
        let sigg = storyListSignal.flatMap(.latest) { (storiesList) -> SignalProducer<[Story],WebErrors> in
            
            let storyDetailsProducers = storiesList.ids.map({ (storyId) -> SignalProducer<Story,WebErrors> in
                let returnSignal = HelperServices.getStoryDetails(storyId: storyId)
                return returnSignal
            })
            
            let sig =  SignalProducer(storyDetailsProducers).flatMap(.concat, transform: { (signal) -> SignalProducer<Story,WebErrors> in
                return signal
            })
            
            return sig.collect()
        }

        return sigg
    }
    
    
    
}
