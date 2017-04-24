import Foundation
import SWXMLHash
#if ReactantRuntime
    import UIKit
    import MapKit
#endif

public class MapView: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "mapType", type: .mapType),
            assignable(name: "isZoomEnabled", key: "zoomEnabled", type: .bool),
            assignable(name: "isScrollEnabled", key: "scrollEnabled", type: .bool),
            assignable(name: "isPitchEnabled", key: "pitchEnabled", type: .bool),
            assignable(name: "isRotateEnabled", key: "rotateEnabled", type: .bool),
            assignable(name: "showsPointsOfInterest", type: .bool),
            assignable(name: "showsBuildings", type: .bool),
            assignable(name: "showsCompass", type: .bool),
            assignable(name: "showsZoomControls", type: .bool),
            assignable(name: "showsScale", type: .bool),
            assignable(name: "showsTraffic", type: .bool),
            assignable(name: "showsUserLocation", type: .bool),
            assignable(name: "isUserLocationVisible", key: "userLocationVisible", type: .bool),
            ] + super.availableProperties
    }

    public override var initialization: String {
        return "MKMapView()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return MKMapView()
    }
    #endif
}
