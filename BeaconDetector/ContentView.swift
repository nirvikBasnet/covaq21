//
//  ContentView.swift
//  BeaconDetector
//
//  Created by Nirvik Basnet on 21/8/21.
//

import Combine
import CoreLocation
import SwiftUI

class BeaconDetector: NSObject,ObservableObject,  CLLocationManagerDelegate{
    var didChange = PassthroughSubject<Void , Never>()
    var locationManager : CLLocationManager?
    var lastDistance = CLProximity.unknown
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager,
                                               didChangeAuthorization status : CLAuthorizationStatus){
        if status == .authorizedWhenInUse{
            if CLLocationManager.isMonitoringAvailable(for:
                CLBeaconRegion.self){
                if CLLocationManager.isRangingAvailable(){
                    startScanning()
                }
            }
            
        }
    }
    func startScanning(){
        let uuid = UUID(uuidString : "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        
        let constraint = CLBeaconIdentityConstraint(uuid: uuid, major: 123, minor: 456)
        
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeacon")
        
        locationManager?.startMonitoring(for : beaconRegion)
        locationManager?.startRangingBeacons(satisfying: constraint)
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first{
            update(distance: beacon.proximity)
            
        }else{
            update(distance: .unknown)
        }
        
    }
    
    func update(distance: CLProximity){
        lastDistance = distance
        didChange.send(())
    }
}



struct ContentView: View {
    @ObservedObject var detector = BeaconDetector()
    var body: some View {
        if detector.lastDistance == .immediate{
            return Text("Vaccinating")
                .modifier(BigText())
                .background(Color.gray)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        }else if detector.lastDistance == .near{
           return Text("In Queue")
                .modifier(BigText())
                .background(Color.gray)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
        }else if detector.lastDistance == .far{
            return Text("Near Vaccine Center")
                .modifier(BigText())
                .background(Color.gray)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
        }else{
            return Text("CoVaQ-21")
                .modifier(BigText())
                .background(Color.gray)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        }
    }
}

struct BigText : ViewModifier{
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 72, design: .rounded))
            .frame(minWidth : 0, maxWidth: .infinity, minHeight:0, maxHeight: .infinity)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
