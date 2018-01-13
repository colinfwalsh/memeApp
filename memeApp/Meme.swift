//
//  Meme.swift
//  memeApp
//
//  Created by Colin Walsh on 1/13/18.
//  Copyright © 2018 Colin Walsh. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    let top: String!
    let bottom: String!
    let image: UIImage!
    let completedImage: UIImage!
    
    var title: String {
        return top + bottom
    }
}
