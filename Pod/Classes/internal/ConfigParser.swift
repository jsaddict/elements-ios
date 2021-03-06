//
//  ConfigParser.swift
//  Tapglue Elements
//
//  Created by John Nilsen  on 14/03/16.
//  Copyright (c) 2015 Tapglue (https://www.tapglue.com/). All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

class ConfigParser {

    func parse(data: NSData) throws  -> Config{
        let defaultConfig = Config()
        
        let configDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data,
            options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        let navigationBarColor = ColorUtil.configColorFromHex(configDictionary["navigationBarColor"] as? String,
            orDefault: defaultConfig.navigationBarColor)
        let navigationBarTextColor = ColorUtil.configColorFromHex(configDictionary["navigationBarTextColor"] as? String,
            orDefault: defaultConfig.navigationBarTextColor)
        let backgroundColor = ColorUtil.configColorFromHex(configDictionary["backgroundColor"] as? String,
            orDefault: defaultConfig.backgroundColor)
        let followBtnDictionary = configDictionary["followButton"] as? [String: AnyObject]
        
        let followButtonConfig: FollowButtonConfig
        if let followBtnDictionary = followBtnDictionary {
            followButtonConfig = FollowButtonParser.parse(followBtnDictionary)
        } else {
            followButtonConfig = FollowButtonConfig()
        }
        
        let roundedImages = configDictionary["roundedImages"] as? Bool ?? defaultConfig.roundedImages
        return Config(navigationBarColor: navigationBarColor, navigationBarTextColor: navigationBarTextColor, backgroundColor: backgroundColor, followButtonConfig: followButtonConfig, roundedImages: roundedImages)
    }
}
