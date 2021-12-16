//
//  ContentView.swift
//  benjominiOS
//
//  Created by k19086kk on 2021/10/17.
//

import SwiftUI
import Combine
import CoreLocation
import FirebaseDatabase
import Foundation
import UserNotifications
import AudioToolbox


class BeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let objectWillChange = ObservableObjectPublisher()
    var locationManager: CLLocationManager!
    var myBeaconRegion:CLBeaconRegion!
    let sub = 0
    


    let UUIDList = [
        "22222222-2222-2222-2222-222222222222",
        "34343434-3434-3434-3434-343434343434"
    ]

    @Published var beaconUUIDs: [String] = []
    @Published var beaconDetails: [String] = []
    @Published var uuid : String = ""
    
    
    override init() {
        super.init()

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge],
            completionHandler: { (granted, error) in })

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }

    func startScanning() {
        for i in 0 ..< UUIDList.count {
            let uuid = UUID(uuidString: "\(UUIDList[i].lowercased())")!
            let constraint = CLBeaconIdentityConstraint(uuid: uuid)
            let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "fabo\(i)")
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(satisfying: constraint)
        }
  
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch (status) {
        case .notDetermined:
            print("未認証の状態")
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted:
            print("制限された状態")
            locationManager.requestAlwaysAuthorization()
            break
        case .denied:
            print("許可しない")
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedAlways:
            print("常に許可")
            startScanning()
            break
        case .authorizedWhenInUse:
            print("このAppの使用中のみ許可")
            startScanning()
            break
        @unknown default:
            break
        }
    }
    func vibrate() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func notification() {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "こもりスマホしていませんか？"
        content.body = "こもりスマホは迷惑行為です"
        content.sound = UNNotificationSound.default
        let request = UNNotificationRequest(identifier: "notification001", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
//    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
//
//        var data: [(UUID: String, major: NSNumber, minor: NSNumber, RSSI: Int)] = []
//
//        for i in 0 ..< beacons.count {
//
//
//            let beacon = beacons[i]
//
//            if beacon.rssi == 0 {
//                break
//            }
//
//
//            var proximity = ""
//
//            switch (beacon.proximity) {
//            case .unknown:
//                proximity = "unknown"
//                break
//            case .immediate:
//                proximity = "immediate"
//                break
//            case .near:
//                proximity = "near"
//                break
//            case .far:
//                proximity = "far"
//                break
//            @unknown default:
//                break
//            }
//
//            data.append(("\(beacon.uuid)", beacon.major, beacon.minor, beacon.rssi))
//
//            beaconUUIDs.append("\(beacon.uuid)")
//
//            var myBeaconDetails = "Major: \(beacon.major) "
//            myBeaconDetails += "Minor: \(beacon.minor) "
//            myBeaconDetails += "Proximity: \(proximity) "
//            myBeaconDetails += "RSSI: \(beacon.rssi) "
//            //print(myBeaconDetails)
//            beaconDetails.append(myBeaconDetails)
//            objectWillChange.send()
//
//
//            let ref = Database.database().reference()
//            ref.child("14:b4:57:a0:cb:4a/state").observe(DataEventType.value, with: {snapshot in
//
//                guard let value = snapshot.value as? Bool else {
//                    return
//                }
//                if value == true {
//
//                    ref.child("14:b4:57:a0:cb:4a/updated_at").observe(DataEventType.value, with: {snapshot in
//                        guard let value = snapshot.value as? Int else {
//                            return
//                        }
//                        let time : Date = Date()
//                        let unixtime: Int = Int(time.timeIntervalSince1970)
//                        let sub = unixtime - value
//                        print("unixtime :\(unixtime)")
//                        print("leafonytime :\(value)")
//                        print(sub)
//                        if sub >= 20{
//                            print("20秒以上います！")
//                            ref.child("14:b4:57:a0:cb:4a/notification-time").observe(DataEventType.value, with: {snapshot in
//                                guard let notifitime = snapshot.value as? Int else {
//                                    return
//                                }
//                                let notifisub = unixtime - notifitime
//                                if  notifisub >= 10{
//                                    ref.child("14:b4:57:a0:cb:4a/notification-time").setValue(unixtime)
//                                    print("通知します")
//
//                                    self.vibrate()
//
//                                    // 通知を呼び出し
//                                    self.notification()
//
//                                }else{
//                                    print("通知しません")
//                                    print("最後に通知してから\(notifisub)秒経ちました")
//                                }
//                                print("Value: \(value)")
//                            })
//                        }
//                    })
//
//
//
//                }else{
//                    //print("空いています")
//                }
//                print("Value: \(value)")
//            })
//
//        }
//
//    }
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if(beacons.count == 0) { return }
        //let beacon = beacons[0] as CLBeacon
        
        //print(beacon.uuid)
        
        let ref = Database.database().reference()
        ref.child("14:b4:57:a0:cb:4a/state").observe(DataEventType.value, with: {snapshot in
            guard let bool = snapshot.value as? Bool else {
                return
            }
            if bool == true {

                ref.child("14:b4:57:a0:cb:4a/updated_at").observe(DataEventType.value, with: {snapshot in
                    guard let value = snapshot.value as? Int else {
                        return
                    }
                    let time : Date = Date()
                    let unixtime: Int = Int(time.timeIntervalSince1970)
                    let sub = unixtime - value
                    //print("unixtime :\(unixtime)")
                    //print("leafonytime :\(value)")
                    //print("sub :\(sub)")
                    if sub >= 20{
                        print("20秒以上います！")
                        ref.child("14:b4:57:a0:cb:4a/notification-time").observe(DataEventType.value, with: {snapshot in
                            guard let notifitime = snapshot.value as? Int else { //notifitimeは最後に通知した時間
                                return
                            }
                            let time2: Date = Date()
                            let unixtime2: Int = Int(time2.timeIntervalSince1970)
                            let notifisub = unixtime2 - notifitime //最後に通知してから何秒経ったか
                            print("notifisub : \(notifisub)")
                            if  notifisub >= 20{
                                ref.child("14:b4:57:a0:cb:4a/notification-time").setValue(unixtime2)
                                print("通知します")

                                self.vibrate()

                                // 通知を呼び出し
                                self.notification()

                            }else{
                                print("通知しません")
                                print("最後に通知してから\(notifisub)秒経ちました \n")
                                print("unixtime2 : \(unixtime2)")
                                print("notifitime : \(notifitime)")
                            }
                            //print("Value: \(value)")
                        })
                    }else{
                        print("通知しません")
                        print("入ってから \(sub)秒経ちました")
                    }
                })
            }else{
                print("空いています")
            }
        })

    }
   
//    func notification() {
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//        let content = UNMutableNotificationContent()
//        content.title = "こもりスマホしていませんか？"
//        content.body = "こもりスマホは迷惑行為です"
//        content.sound = UNNotificationSound.default
//        let request = UNNotificationRequest(identifier: "notification001", content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
////        UNUserNotificationCenter.current().add(request) { (error : Error?) in
////            if let error = error {
////                print(error.localizedDescription)
////            }
////        }
//    }

}

//struct ContentView: View {
//    @ObservedObject var detector = BeaconDetector()
//
//    @State var message = ""
//
//
//
//    var body: some View {
//
//
//        VStack {
//            Text(message)
//                .font(.system(size: 70, weight: .black, design: .default))
//                .foregroundColor(.red)
//                .padding()
//        }.onAppear {
////            let time : Date = Date()
//            let ref = Database.database().reference()
//
//            ref.child("14:b4:57:a0:cb:4a/state").observe(DataEventType.value, with: {snapshot in
//                //データが変更されるたびにターミナル上で変更を知らせる
//                //database.child("この中身")　がデータベースから読み取るためのキーワードになっている
//                guard let value = snapshot.value as? Bool else {
//                    return
//                }
//                if value == true {
//                    print("使用中です")
//                    //print(time)
//                    self.message = "使用中です"
//
//                }else{
//                    print("空いています")
//                    //print(time)
//                    self.message = "空いています"
//                }
//                print("Value: \(value)")
//            })
//
//        }
//    }
//
//}
struct ContentView: View {
  @ObservedObject var detector = BeaconDetector()
  @State var message = ""
  var body: some View {
    NavigationView {
          VStack {
            List{
              Text("4号館1階    :🚹:満室 :🚺:空室").padding()
              Text("4号館2階    :🚹:\(message) :🚺:満室").padding()
              Text("4号館3階    :🚹:空室 :🚺:空室").padding()
              Text("4号館4階    :🚹:空室 :🚺:満室").padding()
            }
            .navigationBarTitle("🚽ベンジョミン🚽")
          }
        }
    .onAppear {
//      let time : Date = Date()
      let ref = Database.database().reference()
      ref.child("14:b4:57:a0:cb:4a/state").observe(DataEventType.value, with: {snapshot in
        //データが変更されるたびにターミナル上で変更を知らせる
        //database.child(“この中身“)　がデータベースから読み取るためのキーワードになっている
        guard let value = snapshot.value as? Bool else {
          return
        }
        if value == true {
          //print("使用中です")
          //print(time)
          self.message = "満室"
        }else{
          print("空いています")
          //print(time)
          self.message = "空室"
        }
        //print("Value: \(value)")
      })
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}

