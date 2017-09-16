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
 
    }
    
    public func getLocalStoriesIDS() ->  SignalProducer<(StoriesList,StoriesList),NoError>
    {
        let instance = DBTopAndNewStories.getInstance()
        
        
        let top = transformToStoryList(instance.top)
        let new = transformToStoryList(instance.new)

        self.topStoriesListIDS = top
        self.newStoriesListIDS = new
        
        
        return SignalProducer(value:(new,top))
    }
    
    private func transformToStoryList(_ list:List<IntObject>) -> StoriesList
    {
        var array:[Int] = []
        for element in list{
            array.append(element.value)
        }
        
        return StoriesList(ids: array)
    }
    
    private func createListFrom(_ list:StoriesList ) -> List<IntObject>
    {
        let array = List<IntObject>()
        for element in list.ids{
            
            let obj = IntObject()
            obj.value = element
            array.append(obj)
        }
        
        return array
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
        
      
        
        let newStoryListSignal = HelperServices.getNewStories()
        let topStoryListSignal = HelperServices.getTopStories()
        
        
        let returnSignal = SignalProducer.combineLatest(newStoryListSignal, topStoryListSignal)
            .flatMap(.latest) { (newStories,topStories) -> SignalProducer<(StoriesList,StoriesList),WebErrors> in
                self.topStoriesListIDS = topStories
                self.newStoriesListIDS = newStories
                let instance = DBTopAndNewStories.getInstance()
                instance.update {
                    instance.top = self.createListFrom(topStories);
                    instance.new = self.createListFrom(newStories);
                }
                
                return SignalProducer(value:(newStories,topStories))
        }
        
        return returnSignal
        
    }
    
    
    public func getAllStories() -> SignalProducer<([DBStory],[DBStory]),WebErrors>
    {
        
        
        let newStoriesSignal = getStoriesDetailList(type: .new)
        let topStoriesSignal = getStoriesDetailList(type: .top)
        
        let returnSignal = SignalProducer.combineLatest(newStoriesSignal, topStoriesSignal)
            .flatMap(.latest) {(newStories, topStories) -> SignalProducer<([DBStory],[DBStory]),WebErrors> in
              
                
                let newS = self.fillDbWithStories(stories: newStories);
                let topS = self.fillDbWithStories(stories: topStories);
                
                return SignalProducer(value:(newS,topS))
                
                
                
            }.doNext { (newStories,topStories) in
                self.newStoriesList =  newStories
                self.topStoriesList = topStories;
                
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
