//
//  LoginInfo.swift
//  Test_Moya
//
//  Created by hoomsun on 2017/6/26.
//  Copyright © 2017年 hoomsun. All rights reserved.
//

import Foundation

fileprivate let HSLoginInfoFileName: String = "/info"

class LoginInfo {
    init() { }
    
    /// 登录后，保存用户信息
    class func saveLoginInfo(with user: HSUser?) {
        guard let user = user else {
            return
        }
        
        let path = filePath(for: HSLoginInfoFileName)
//        let savedSuccess = NSKeyedArchiver.archiveRootObject(user, toFile: path)
        let fileData = NSKeyedArchiver.archivedData(withRootObject: user) as NSData
        let savedSuccess = fileData.write(toFile: path, atomically: true)
        
        if savedSuccess {
            print(message: "用户信息保存成功")
        } else {
            print(message: "用户信息保存失败")
        }
    }
    
    /// 获取保存的用户登录信息
    class func savedLoginInfo() -> HSUser? {
        let path = filePath(for: HSLoginInfoFileName)
        var model = NSKeyedUnarchiver.unarchiveObject(withFile: path)
        guard model != nil else { return nil }
        
        model = model as? HSUser
        if let model = model {
            return (model as! HSUser)
        } else {
            return nil
        }
    }
    
    /// 删除保存的登录信息
    class func removeSavedLoginInfo() -> Bool {
        let path = filePath(for: HSLoginInfoFileName)
        let fileExist = FileManager.default.fileExists(atPath: path)
        if fileExist {
            do {
                try FileManager.default.removeItem(atPath: path)
                return true
            } catch {
                print(message: error)
                return false
            }
        } else {
            return true
        }
    }
    
    /// 获取钥匙串中的UUID，如果没有则创建并保存
    class func fetchUUID() -> String? {
        let user: HSUser? = savedLoginInfo()
        
        if let user = user, let uuid = user.UUID {
            return uuid
        } else {
            return UUID().uuidString
        }
    }
}

func filePath(for name: String) -> String {
    let array = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
    return (array.first?.appending(name))!
}
