//
//  utils.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import Foundation
import ReactiveSwift


extension SignalProducer
{
    public func doNext(callBack:@escaping (_ value:Value) -> Void) -> SignalProducer<Value,Error>
    {
        return self.on(starting: nil, started: nil, event: {(event) -> Void in
            if let v = event.value{
                callBack(v)
            }
        }, failed: nil, completed: nil, interrupted: nil, terminated: nil, disposed: nil, value: nil)
    }
    public func doError(callBack:@escaping (_ value:Error) -> Void) -> SignalProducer<Value,Error>
    {
        
        
        return self.on(starting: nil, started: nil, event: { (event) in
            if let er = event.error{
                callBack(er);
            }
            
        }, failed: {error in
            callBack(error);
        }, completed: nil, interrupted: nil, terminated: nil, disposed: nil, value: nil)
    }
    
    public func continueWithSelfIfError(_ callback:@escaping (_ error:Error) -> Void) -> SignalProducer
    {
        return self.flatMapError { (error) -> SignalProducer<Value, Error> in
            callback(error)
            return self.continueWithSelfIfError(callback)
        }
    }
}

extension Signal
{
    public func doNext(callBack:@escaping (_ value:Value) -> Void) -> Signal<Value,Error>
    {
        return self.on(event: nil, failed: nil, completed: nil, interrupted: nil, terminated: nil, disposed: nil) { (value) in
            
            callBack(value)
            
        }
        
    }
    
    public func doError(callBack:@escaping (_ value:Error) -> Void) -> Signal<Value,Error>
    {
        return self.on(event: nil, failed: { (error) in
            callBack(error);
        }, completed: nil, interrupted: nil, terminated: nil, disposed: nil, value: nil)
        
    }
}
