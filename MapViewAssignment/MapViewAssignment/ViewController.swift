//
//  ViewController.swift
//  MapViewAssignment
//
//  Created by 김재석 on 1/16/24.
//

import UIKit
import CoreLocation  // 1. 위치 권한 가져오기 위해 라이브러리 불러오기
import MapKit

class ViewController: UIViewController {

    let latitude = 37.6543
    let longitude = 127.0498
    var beforeCoordinate: CLLocationCoordinate2D? = nil
    @IBOutlet var mapView: MKMapView!
    
    // locationManager 인스턴스 생성
    let locationManager = CLLocationManager()

    let theaterOriginal = Theater.mapAnnotations
    var theater = Theater.mapAnnotations {
        didSet {
            setMapView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        checkDeviceLocationAuthorization()
        configureView()
        setBarButtonItem()
        setMapView()
    }
        
    @objc func rightBarButtonOnClick() {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let mega = UIAlertAction(
            title: "메가박스",
            style: .default) {_ in
            self.theater = self.theaterOriginal.filter { item in
                item.type == "메가박스"
                }
            }
        
        let lotte = UIAlertAction(
            title: "롯데시네마",
            style: .default) { _ in
                self.theater = self.theaterOriginal.filter { item in
                    item.type == "롯데시네마"
                }
            }
        let cgv = UIAlertAction(
            title: "CGV",
            style: .default) { _ in
                self.theater = self.theaterOriginal.filter { item in
                    item.type == "CGV"
                }
            }
        let total = UIAlertAction(
            title: "전체 보기",
            style: .default) { _ in
                self.theater = self.theaterOriginal
            }
        let cancel = UIAlertAction(
            title: "취소",
            style: .cancel
        )
        
        alert.addAction(mega)
        alert.addAction(lotte)
        alert.addAction(cgv)
        alert.addAction(total)
        alert.addAction(cancel)
        
        present(alert, animated:true)
    }
    
    @objc func leftBarButtonOnClick() {
        checkDeviceLocationAuthorization()
        if let beforeCoordinate {
            let region = MKCoordinateRegion(
                center: beforeCoordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            mapView.setRegion(region, animated: true)
        }
    }
}

// UI 관련 extensions
extension ViewController {
    func configureView() {
        navigationItem.title = "영화관 찾기"
    }
    
    func setBarButtonItem() {
        let rightButton = UIBarButtonItem(
            image: ImageStyle.search,
            style: .plain,
            target: self,
            action: #selector(rightBarButtonOnClick)
        )
        let leftButton = UIBarButtonItem(
            image: UIImage(systemName: "map"),
            style: .plain,
            target: self,
            action: #selector(leftBarButtonOnClick)
        )
        navigationItem.rightBarButtonItems = [rightButton, leftButton]
        
        
    }
}

extension ViewController {
    func setMapView () {
        mapView.removeAnnotations(mapView.annotations)
        let coordinate = CLLocationCoordinate2D(
            latitude: 37.5,
            longitude: 126.96
        )
        
        // center를 중심으로 반경 몇 미터 보여줄 지
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 15000,
            longitudinalMeters: 15000
        )
        
        mapView.setRegion(region, animated: true)
        
        // annotation 설정
        for item in theater {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(
                latitude: item.latitude,
                longitude: item.longitude
            )
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    // 디바이스 자체 위치 권한 정보 확인
    func checkDeviceLocationAuthorization() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                let authorization: CLAuthorizationStatus
                
                if #available(iOS 14, *) {
                    authorization = self.locationManager.authorizationStatus
                } else {
                    authorization = CLLocationManager.authorizationStatus()
                }
                DispatchQueue.main.async {
                    self.checkCurrentLocationAuthorization(status: authorization)
                }
            } else {
                print("위치 서비스가 꺼져 있어서 위치 권한 요청을 할 수 없습니다.")
            }
        }
    }
    
    // 사용자 위치 권한 상태 확인 후 권한 요청
    func checkCurrentLocationAuthorization(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("Not Determined")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest  // 위치 정확도
            locationManager.requestWhenInUseAuthorization()  // 권한 문구 띄우기(plist와 동일)
        case .denied:
            showLocationSettingAlert()
            let coordinate = CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            )
            
            // center를 중심으로 반경 몇 미터 보여줄 지
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            )
            
            mapView.setRegion(region, animated: true)
        case .authorizedWhenInUse:
            // didUpdateLocation 메서드 실행
            print("wheninuse")
            locationManager.startUpdatingLocation()
        default:
            print("ERROR")
        }
    }
    
    // 앱 위치 정보 이용 거부 눌렀을 때
    func showLocationSettingAlert() {
        let alert = UIAlertController(
            title: "위치 정보 이용",
            message: "위치 서비스를 사용할 수 없습니다. 기기의 '설정 > 개인정보보호'에서 위치 서비스를 켜 주세요",
            preferredStyle: .alert
        )
        let goSetting = UIAlertAction(
            title: "설정으로 이동",
            style: .default) { _ in
                if let setting = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(setting)
                } else {
                    print("설정으로 가 주세요")
                }
            }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(goSetting)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let beforeCoordinate {
            let removeAnnotation = MKPointAnnotation()
            removeAnnotation.coordinate = beforeCoordinate
            mapView.removeAnnotation(removeAnnotation)
        }
        
        if let coordinate = locations.last?.coordinate {
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            beforeCoordinate = coordinate
            print(coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)
    }
    
    // 사용자 권한 상태 바뀔 때 실행되는 함수
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviceLocationAuthorization()
    }
    
    // under iOS 14
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function)
    }
}
