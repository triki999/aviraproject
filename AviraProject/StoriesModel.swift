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
import Result

class StorieModel
{
    enum StoryType
    {
        case new, top
    }
    
    public static let  instance:StorieModel = StorieModel()
    
    var topStoriesList:[DBStory]?
    var newStoriesList:[DBStory]?
    
    var topStoriesListIDS:StoriesList?
    var newStoriesListIDS:StoriesList?
    
    private init()
    {
        
        //getAllStories
        getAllStoriesIDS().startWithCompleted {[weak self] in

        }
        
    }
    
    public func getAllReadLaterStories() -> SignalProducer<[DBStory],NoError>
    {
        
        let signal = SignalProducer<[DBStory],NoError>{ (observer, disposable) in
            let realm = try! Realm()
            let query = "stateRaw == \(DBStory.StoryState.readLater.rawValue)"
            
            let _dbStory = realm.objects(DBStory.self).filter(query)
            var array:[DBStory] = []
            for stor in _dbStory{
                array.append(stor)
            }
            observer.send(value: array)
            observer.sendCompleted()
           
        }.observe(on: UIScheduler())
        
        return signal;
        
        
    }
    
    
    public func getStorySignal(storyId:Int) -> SignalProducer<DBStory, WebErrors>
    {
        
        
        let realm = try! Realm()
        let query = "id == \(storyId)"
        
        if let _dbStory = realm.objects(DBStory.self).filter(query).first
        {
            return SignalProducer(value: _dbStory)
        }
        
        
        let returnSignal = HelperServices.getStoryDetails(storyId: storyId).flatMap(.latest) {[weak self] (story) -> SignalProducer<DBStory, WebErrors> in
            guard let dbStory = self?.createDBStoryEntry(story: story) else {
                return SignalProducer.empty
            }
            return SignalProducer(value: dbStory)
        }.observe(on: UIScheduler())
        
        return returnSignal;
    }
    
    public func changeStoryStatus(_ dbStory:DBStory,state:DBStory.StoryState) -> DBStory.StoryState
    {
        dbStory.update {
            dbStory.state = state
        }
        
        return dbStory.state
    }
    
    
    public func clearModel()
    {
        topStoriesList = nil;
        newStoriesList = nil;
        
        topStoriesListIDS = nil;
        newStoriesListIDS = nil;
    }
    
    
    public func getAllStoriesIDS() -> SignalProducer<(StoriesList,StoriesList),WebErrors>
    {
        
        if let _ = topStoriesListIDS, let _ = newStoriesListIDS {
            return SignalProducer(value:(newStoriesListIDS!,topStoriesListIDS!))
        }
        
        let newStoryListSignal = HelperServices.getNewStories()
        let topStoryListSignal = HelperServices.getTopStories()
        
        
        let returnSignal = SignalProducer.combineLatest(newStoryListSignal, topStoryListSignal)
            .flatMap(.latest) {[weak self] (newStories,topStories) -> SignalProducer<(StoriesList,StoriesList),WebErrors> in
                guard let wSelf = self else {
                    return SignalProducer.empty
                }
                wSelf.topStoriesListIDS = topStories;
                wSelf.newStoriesListIDS = newStories
                
                return SignalProducer(value:(newStories,topStories))
        }
        
        return returnSignal
        
    }
    
    
    public func getAllStories() -> SignalProducer<([DBStory],[DBStory]),WebErrors>
    {
        
        
        let newStoriesSignal = getStoriesDetailList(type: .new)
        let topStoriesSignal = getStoriesDetailList(type: .top)
        
        let returnSignal = SignalProducer.combineLatest(newStoriesSignal, topStoriesSignal)
            .flatMap(.latest) {[weak self] (newStories, topStories) -> SignalProducer<([DBStory],[DBStory]),WebErrors> in
                guard let wSelf = self else {
                    return SignalProducer.empty
                }
                
                
                let newS = wSelf.fillDbWithStories(stories: newStories);
                let topS = wSelf.fillDbWithStories(stories: topStories);
                
                return SignalProducer(value:(newS,topS))
                
                
                
            }.doNext {[weak self] (newStories,topStories) in
                self?.newStoriesList =  newStories
                self?.topStoriesList = topStories;
                
        }
        
        return returnSignal;
        
    }
    
    private func fillDbWithStories(stories:[Story]) -> [DBStory]
    {
        
        
        let storyCellsArray = stories.flatMap { (story) -> DBStory? in
            let realm = try! Realm()
            let query = "id == \(story.id)"
            
            var dbStory:DBStory!
            
            if let _dbStory = realm.objects(DBStory.self).filter(query).first
            {
                dbStory = _dbStory
            }else{
                
                dbStory = createDBStoryEntry(story: story)
            }
            
            return dbStory
        }
        
        return storyCellsArray;
        
    }
    
    private func createDBStoryEntry(story:Story) -> DBStory
    {
        let dbStory = DBStory()
        dbStory.update {
            dbStory.id = story.id;
            dbStory.state = .unread
            dbStory.time = RealmOptional(story.time);
            dbStory.url = story.url
            dbStory.title = story.title
        }
        dbStory.addToRealm()
        
        return dbStory;
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
        
        
        let returnSignal = storyListSignal.flatMap(.latest) { (storiesList) -> SignalProducer<[Story],WebErrors> in
            
            let storyDetailsProducers = storiesList.ids.map({ (storyId) -> SignalProducer<Story,WebErrors> in
                let returnSignal = HelperServices.getStoryDetails(storyId: storyId)
                return returnSignal
            })
            
            let sig =  SignalProducer(storyDetailsProducers).flatMap(.concat, transform: { (signal) -> SignalProducer<Story,WebErrors> in
                return signal
            })
            
            return sig.collect()
        }
        
        return returnSignal
    }
    
    
    
}
