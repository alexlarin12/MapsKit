//
//  ViewController.swift
//  MapsKit
//
//  Created by Alex Larin on 21.02.2021.
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift

class ViewController: UIViewController {
   
    // Ячейка для хранения Маркера:
    var marker: GMSMarker?
    var locationManager: CLLocationManager!
    // Ячейка для хранения объекта маршрута:
    var route: GMSPolyline?
    // Ячейка для хранения объекта пути:
    var routePath: GMSMutablePath?

    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        configureMap()
        
    }
    
    func configureMap() {
        // Центр Москвы
        let coordinate = CLLocationCoordinate2D(latitude: 59.939095, longitude: 30.315868)
        // Создаём камеру с использованием координат и уровнем увеличения
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        // Устанавливаем камеру для карты
        mapView.camera = camera
        // Установка кнопки для возврата к текущему местоположению пользователя.
        mapView.settings.myLocationButton = true
        // Компас.
        mapView.settings.compassButton = true
        // Установить точку, обозначающую геопозицию и окружность, обозначающую точность определения геопозиции.
        mapView.isMyLocationEnabled = true
    }
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        // разрешение на работу геолокации в фоне:
        locationManager?.allowsBackgroundLocationUpdates = true
        // остановка работы геолокации при паузе в движении:
        locationManager?.pausesLocationUpdatesAutomatically = false
        // старт приложения при перемещении объекта на знеачительное расстояние(более 500м):
        locationManager?.startMonitoringSignificantLocationChanges()
        // точность отслеживания перемещения:
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // Запрос разрешения на работу геолокации в фоне:
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestAlwaysAuthorization()
        // Начать отслеживать геопозицию.
        locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func updateLocation(_ sender: Any) {
       
    }
    
    @IBAction func currentLocation(_ sender: Any) {
        
    }
    
    @IBAction func startTrackingLocation(_ sender: Any) {
        // Создание линии пути
        addLine()
        // Запускаем отслеживание или продолжаем, если оно уже запущено
        locationManager?.startUpdatingLocation()
    }
    
    @IBAction func stopTrackingLocation(_ sender: Any) {
        locationManager?.stopUpdatingLocation()
        // locationManager?.requestLocation()
        // Удалить предыдущий маршрут из Realm.
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print(error)
        }
        addLastRoute()
    }
    
    @IBAction func lastRouteLocation(_ sender: Any) {
        lastRoute()
    }
    
    // метод добавления линии пути:
    func addLine() {
        // Отвязываем от карты старую линию
     //   route?.map = nil
        // Заменяем старую линию новой
        route = GMSPolyline()
        // цвет объекта пути:
        route?.strokeColor = .red
        // ширина объекта пути:
        route?.strokeWidth = 7
        // Заменяем старый путь новым, пока пустым (без точек)
        routePath = GMSMutablePath()
        // Добавляем новую линию на карту
        route?.map = mapView
    }
    // метод добавления маркера:
    func addMarker(position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.map = mapView
        self.marker = marker
        mapView.animate(toLocation: position)
        
    }
    // метод удаления маркера:
    func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    // Сохранение маршрута в Realm.
    func addLastRoute() {
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
            guard let routePath = routePath else { return }
            // Цикл по всем точкам (координатам) маршрута.
            for i in 0..<routePath.count() {
                let currentCoordinate = routePath.coordinate(at: i)
                lastRoute.latitude = currentCoordinate.latitude
                lastRoute.longitude = currentCoordinate.longitude
                // Кладем все объекты класса CLLocation в хранилище.
                realm.add(lastRoute)
            }
            // Завершаем изменения хранилища.
            try realm.commitWrite()
        } catch {
            // Если произошла ошибка, выводим ее в консоль.
            print(error)
        }
    }
    // Показ предыдущего маршрута.
    func lastRoute() {
        
        // Получаем доступ к хранилищу.
        let realm = try! Realm()
        let lastRoute: Results<LastRoute> = { realm.objects(LastRoute.self) }()
        // Проверка, что координаты есть в памяти.
        guard !lastRoute.isEmpty else { return }
        addLine()
        // Создание линии маршрута путём перебора всех координат.
        for coordinates in lastRoute {
            routePath?.add(CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude))
            route?.path = routePath
        }
        // Первая точка маршрута.
        let firstCoordinates = CLLocationCoordinate2D(latitude: lastRoute.first!.latitude, longitude: lastRoute.first!.longitude)
        // Последняя точка маршрута.
        let lastCoordinates = CLLocationCoordinate2D(latitude: lastRoute.last!.latitude ,longitude: lastRoute.last!.longitude)
        // Определение границ маршрута.
        let bounds = GMSCoordinateBounds(coordinate: firstCoordinates, coordinate: lastCoordinates)
        // Установка камеры относительно поределённых границ.
        let camera = mapView.camera(for: bounds, insets: UIEdgeInsets())!
        mapView.camera = camera
        // Немного отодвинуть камеру, чтобы был зазор между краями экрана и крайними точками линии маршрута.
        mapView.moveCamera(GMSCameraUpdate.zoomOut())
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Берём последнюю точку из полученного набора
        guard let location = locations.last else { return }
        // Добавляем её в путь маршрута
        routePath?.add(location.coordinate)
        // Обновляем путь у линии маршрута путём повторного присвоения
        route?.path = routePath
       
        // Чтобы наблюдать за движением, установим камеру на только что добавленную точку:
        let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15)
        
        mapView.animate(to: camera)
        // Удаление предыдущего маркера:
        removeMarker()

        addMarker(position: location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
