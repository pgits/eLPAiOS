import Foundation
import UIKit

class NavigationHelper {
    // MARK: - First Question cordinates
    class func firstQuestionX() -> Int {
        let x:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            x = 17
        case 568: // 5
            x = 17
        case 667: // 6
            x = 0
        case 736: // 6 plus
            x = 16
        default: // 6
            x = 0
        }
        return x
    }
    
    class func firstQuestionY() -> Int {
        let y:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            y = 445
        case 568: // 5
            y = 530
        case 667: // 6
            y = 623
        case 736: // 6 plus
            y = 687
        default: // 6
            y = 623
        }
        return y
    }
    
    class func firstQuestionW() -> Int {
        let W:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            W = 32
        case 568: // 5
            W = 30
        case 667: // 6
            W = 46
        case 736: // 6 plus
            W = 35
        default: // 6
            W = 46
        }
        return W
    }
    
    class func firstQuestionH() -> Int {
        let H:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            H = 30
        case 568: // 5
            H = 30
        case 667: // 6
            H = 30
        case 736: // 6 plus
            H = 30
        default: // 6
            H = 30
        }
        return H
    }
    
    // MARK: - Previous Question cordinates
    class func previousQuestionX() -> Int {
        let x:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            x = 57
        case 568: // 5
            x = 43
        case 667: // 6
            x = 70
        case 736: // 6 plus
            x = 50
        default: // 6
            x = 70
        }
        return x
    }
    
    class func previousQuestionY() -> Int {
        let y:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            y = 445
        case 568: // 5
            y = 530
        case 667: // 6
            y = 623
        case 736: // 6 plus
            y = 687
        default: // 6
            y = 623
        }
        return y
    }
    
    class func previousQuestionW() -> Int {
        let W:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            W = 27
        case 568: // 5
            W = 30
        case 667: // 6
            W = 31
        case 736: // 6 plus
            W = 35
        default: // 6
            W = 31
        }
        return W
    }
    
    class func previousQuestionH() -> Int {
        let H:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            H = 30
        case 568: // 5
            H = 30
        case 667: // 6
            H = 30
        case 736: // 6 plus
            H = 30
        default: // 6
            H = 30
        }
        return H
    }
    
    // MARK: - Label cordinates
    class func labelX() -> Int {
        let x:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            x = 155
        case 568: // 5
            x = 156
        case 667: // 6
            x = 180
        case 736: // 6 plus
            x = 203
        default: // 6
            x = 180
        }
        return x
    }
    
    class func labelY() -> Int {
        let y:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            y = 450
        case 568: // 5
            y = 535
        case 667: // 6
            y = 623
        case 736: // 6 plus
            y = 694
        default: // 6
            y = 623
        }
        return y
    }
    
    class func labelW() -> Int {
        let W:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            W = 29
        case 568: // 5
            W = 29
        case 667: // 6
            W = 46
        case 736: // 6 plus
            W = 34
        default: // 6
            W = 46
        }
        return W
    }
    
    class func labelH() -> Int {
        let H:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            H = 21
        case 568: // 5
            H = 29
        case 667: // 6
            H = 30
        case 736: // 6 plus
            H = 21
        default: // 6
            H = 30
        }
        return H
    }
    
    // MARK: - Next Question cordinates
    class func nextQuestionX() -> Int {
        let x:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            x = 240
        case 568: // 5
            x = 243
        case 667: // 6
            x = 270
        case 736: // 6 plus
            x = 328
        default: // 6
            x = 270
        }
        return x
    }
    
    class func nextQuestionY() -> Int {
        let y:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            y = 445
        case 568: // 5
            y = 530
        case 667: // 6
            y = 623
        case 736: // 6 plus
            y = 687
        default: // 6
            y = 623
        }
        return y
    }
    
    class func nextQuestionW() -> Int {
        let W:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            W = 27
        case 568: // 5
            W = 30
        case 667: // 6
            W = 45
        case 736: // 6 plus
            W = 30
        default: // 6
            W = 45
        }
        return W
    }
    
    class func nextQuestionH() -> Int {
        let H:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            H = 30
        case 568: // 5
            H = 30
        case 667: // 6
            H = 30
        case 736: // 6 plus
            H = 30
        default: // 6
            H = 30
        }
        return H
    }
    
    // MARK: Last Question cordinates
    class func lastQuestionX() -> Int {
        let x:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            x = 275
        case 568: // 5
            x = 274
        case 667: // 6
            x = 317
        case 736: // 6 plus
            x = 360
        default: // 6
            x = 317
        }
        return x
    }
    
    class func lastQuestionY() -> Int {
        let y:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            y = 445
        case 568: // 5
            y = 530
        case 667: // 6
            y = 623
        case 736: // 6 plus
            y = 687
        default: // 6
            y = 623
        }
        return y
    }
    
    class func lastQuestionW() -> Int {
        let W:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            W = 32
        case 568: // 5
            W = 30
        case 667: // 6
            W = 46
        case 736: // 6 plus
            W = 35
        default: // 6
            W = 46
        }
        return W
    }
    
    class func lastQuestionH() -> Int {
        let H:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            H = 30
        case 568: // 5
            H = 30
        case 667: // 6
            H = 30
        case 736: // 6 plus
            H = 30
        default: // 6
            H = 30
        }
        return H
    }
    
    // MARK: - Pagination view cordinates
    class func paginationViewY() -> Int {
        let y:Int!
        switch (Config.SCREEN_HEIGHT) {
        case 480: // 4s
            y = 442
        case 568: // 5
            y = 527
        case 667: // 6
            y = 620
        case 736: // 6 plus
            y = 690
        default: // 6
            y = 620
        }
        return y
    }
    
}
