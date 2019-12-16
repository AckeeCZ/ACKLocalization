//
//  main.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import ACKLocalizationCore
import Foundation
import Reqres

#if DEBUG
Reqres.register()
#endif

let localization = ACKLocalization()

localization.run()
