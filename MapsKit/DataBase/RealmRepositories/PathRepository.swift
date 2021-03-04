//
//  PathRepositories.swift
//  MapsKit
//
//  Created by Alex Larin on 04.03.2021.
//

import Foundation
import RealmSwift
import CoreLocation
import GoogleMaps

class PathRepository{
    // Сохранение маршрута в Realm.
    func addLastRoute(routePath: GMSMutablePath) {
        let lastRoute = LastRoute()
        // Обработка исключений при работе с хранилищем.
        do {
            // Получаем доступ к хранилищу.
            let config = Realm.Configuration(deleteRealmIfMigrationNeeded:false)
            let realm = try Realm(configuration: config)
            // Путь к хранилищу.
            print(Realm.Configuration.defaultConfiguration.fileURL!)
            
            // Начинаем изменять хранилище.
            realm.beginWrite()
            // realm.deleteAll()
            let routePath = routePath 
            // Цикл по всем точкам (координатам) маршрута.
            for i in 0..<routePath.count() {
                let currentCoordinate = routePath.coordinate(at: i)
                lastRoute.latitude = currentCoordinate.latitude
                lastRoute.longitude = currentCoordinate.longitude
                // Кладем все объекты класса CLLocation в хранилище.
                realm.add(lastRoute)
            }
            // Кладем все объекты класса CLLocation в хранилище.
            realm.add(lastRoute)
            // Завершаем изменения хранилища.
            try realm.commitWrite()
        } catch {
            // Если произошла ошибка, выводим ее в консоль.
            print(error)
        }
    }
    
    // метод получения пути пользователя из Realm:
    func getPathData() throws -> Results<LastRoute> {
        do{
            let realm = try Realm()
            return realm.objects(LastRoute.self)
        }catch{
            throw error
        }
    }
    // метод очистки БД
    func clearDB(){
        do{
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
            
        }catch{
            print(error)
        }
    }
}
