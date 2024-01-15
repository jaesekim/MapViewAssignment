//
//  ViewController.swift
//  MapViewAssignment
//
//  Created by 김재석 on 1/16/24.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    
    @IBOutlet var mapView: MKMapView!
    let theaterOriginal = Theater.mapAnnotations
    let theater = Theater.mapAnnotations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            style: .default
        )
        
        let lotte = UIAlertAction(
            title: "롯데시네마",
            style: .default
        )
        let cgv = UIAlertAction(
            title: "CGV",
            style: .default
        )
        let total = UIAlertAction(
            title: "전체 보기",
            style: .default,
            
        ),
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
    
    func handleAlert() {
        mapView.reloadInputViews()
    }
}

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
        
        navigationItem.rightBarButtonItem = rightButton
    }
}

extension ViewController {
    func setMapView () {
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
        for item in theaterOriginal {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(
                latitude: item.latitude,
                longitude: item.longitude
            )
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
}
