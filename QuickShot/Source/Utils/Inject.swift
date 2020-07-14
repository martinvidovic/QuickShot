//
//  Inject.swift
//  QuickShot
//
//  Created by Martin Vidovic on 14/07/2020.
//  Copyright © 2020 Martin Vidovic. All rights reserved.
//

@propertyWrapper
struct Inject<Component>{
    var component: Component

    init(){
        self.component = Resolver.shared.resolve(Component.self)
    }
    
    public var wrappedValue:Component{
        get { return component}
        mutating set { component = newValue }
    }
}
