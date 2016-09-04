//
//  Utility.swift
//  Zapper
//
//  Created by Niranjan Ravichandran on 04/09/16.
//  Copyright © 2016 nravichan. All rights reserved.
//

import UIKit

class Utility {
    
    //App utility methods
    
    class var appBaseColor: UIColor {
        
        return UIColor(red: 87/255, green: 0/255, blue: 192/255, alpha: 1.0)
    }
    
}

extension NSData {
    
    func getJSON() -> AnyObject? {
        
        do {
            let parsed = try NSJSONSerialization.JSONObjectWithData(self, options: .AllowFragments)
            return parsed
        }catch {
            NSLog("Could not parse JSON")
            return nil
        }
    }
}