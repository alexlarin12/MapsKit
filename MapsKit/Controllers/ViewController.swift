//
//  ViewController.swift
//  MapsKit
//
//  Created by Alex Larin on 21.02.2021.
//

import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController {
   
    // Ячейка для хранения Маркера:
    var marker: GMSMarker?
    var locationManager: CLLocationManager!
    // Ячейка для хранения объекта маршрута:
    var route: GMSPolyline?
    // Ячейка для хранения объекта пути:
    var routePath: GMSMutablePath?
    // Ячейка для хранения объекта БД:
    let dataBase = PathRepository()

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
        dataBase.clearDB()
        // Добавить маршрут в БД:
        guard let routePath = routePath else {return}
        dataBase.addLastRoute(routePath:routePath)
    }
    
    @IBAction func lastRouteLocation(_ sender: Any) {
        lastRoute()
    }
    // метод добавления линии пути:
    func addLine() {
        // Заменяем старую линию новой
        route = GMSPolyline()
        // Заменяем старый путь новым, пока пустым (без точек)
        routePath = GMSMutablePath()
        // Добавляем новую линию на карту
        route?.map = mapView
        // цвет объекта пути:
        route?.strokeColor = .red
        // ширина объекта пути:
        route?.strokeWidth = 7
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
    // метод построения предыдущего маршрута.
    func lastRoute() {
        // Получаем путь из хранилища:
        let lastRoute = try! dataBase.getPathData()
        // Проверка, что координаты есть в памяти.
        guard !lastRoute.isEmpty else { return }
        // Заменяем старую линию новой.
        route = GMSPolyline()
        // Заменяем старый путь новым, пока пустым (без точек).
        routePath = GMSMutablePath()
        // Добавляем новую линию на карту.
        route?.map = mapView
        // Цвет и ширина линии маршрута.
        route?.strokeWidth = 5
        route?.strokeColor = .systemRed
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
     //   let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
     //   mapView.moveCamera(update)
        
        
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
