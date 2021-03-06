//
//  dbobjects.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import Foundation

import RealmSwift


public class RealmUpdater: Object {
    internal var realmOBJ: Realm {
        get {
            return try! Realm();
        }
    }
    public func update(_ updateBlock: @escaping () -> Void) -> Void {
        if (self.isInvalidated) {
            return;
        }
        try! realmOBJ.write {
            updateBlock()
        }
    }
    
    public func addToRealm() {
        try! realmOBJ.write {
            realmOBJ.add(self)
        }
    }
    public func delete()
    {
        try! realmOBJ.write {
            realmOBJ.delete(self)
        }
    }
}

public class DBStory : RealmUpdater
{
    enum StoryState: Int {
        case unread = 1
        case read = 2
        case readLater = 3
    }
    
    dynamic var id = -1;
    dynamic var stateRaw = 1
    var time = RealmOptional<Double>();
    dynamic var title: String?;
    dynamic var url: String?;
    var state: DBStory.StoryState {
        get {
            if let a = DBStory.StoryState.init(rawValue: stateRaw) {
                return a
            }
            return .unread
        }
        set {
            stateRaw = newValue.rawValue
        }
    }
    
}
class IntObject: Object {
    dynamic var value = -1
}

public class DBTopAndNewStories : RealmUpdater
{
    var top = List<IntObject>()
    var new = List<IntObject>()
    
    static func getInstance() -> DBTopAndNewStories{
        
        let realm =  try! Realm();
        guard let obj = realm.objects(DBTopAndNewStories.self).first else {
            let instance = DBTopAndNewStories()
            instance.addToRealm()
            return instance
        }
        
        return obj;
    }
}

