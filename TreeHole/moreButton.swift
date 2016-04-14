//
//  moreButton.swift
//  TreeHole
//
//  Created by David on 16/4/12.
//  Copyright (c) 2016年 David. All rights reserved.
//

import UIKit

class moreButton: UIButton {

    var ubelong:Int!
    var textid:Int!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    init(frame:CGRect, uid:Int, tid:Int){
        super.init(frame:frame)
        ubelong = uid
        textid = tid
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
