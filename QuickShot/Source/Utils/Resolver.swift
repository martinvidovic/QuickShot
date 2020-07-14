//
//  Resolver.swift
//  QuickShot
//
//  Created by Martin Vidovic on 14/07/2020.
//  Copyright © 2020 Martin Vidovic. All rights reserved.
//

protocol Component { }
class Resolver{
  
    static let shared = Resolver()
    var factoryDict: [String: () -> Component] = [:]
    
    func add(type: Component.Type, _ factory: @escaping () -> Component) {
        factoryDict[String(describing: type.self)] = factory
    }

    func resolve<Component>(_ type: Component.Type) -> Component {
        let component: Component = factoryDict[String(describing:Component.self)]?() as! Component
        return component
    }
}
