//
//  Post.swift
//  MySelfiegram
//
//  Created by Daniel Mathews on 2015-11-05.
//  Copyright © 2015 Daniel Mathews. All rights reserved.
//

import UIKit

class Post {
    
    let imageURL:NSURL
    //e.g. imageURL: https://farm1.staticflickr.com/582/22992326269_b6c8fdff52.jpg
    let user:User
    let comment:String
    
    init(imageURL:NSURL, user:User, comment:String){
        // You can name the property you are passing into the function the
        // same name as the class' property. To distinguish the two
        // add "self." to the beginning of the class' property.
        // So for example we are passing in an NSURL called imageURL and setting it as our
        // imageURL property for Post.
        self.imageURL = imageURL
        self.user = user
        self.comment = comment
    }

}





