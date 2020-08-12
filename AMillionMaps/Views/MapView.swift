//
//  MapView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 30.06.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation

import Combine
import Mapbox
import Resolver
import SwiftUI

func signedPolygonArea(polygon: [CGPoint]) -> CGFloat {
    let nr = polygon.count
    var area: CGFloat = 0
    for i in 0 ..< nr {
        let j = (i + 1) % nr
        area = area + polygon[i].x * polygon[j].y
        area = area - polygon[i].y * polygon[j].x
    }
    area = area/2.0
    return area
}

func polygonCenterOfMass(polygon: [CGPoint]) -> CGPoint {
    let nr = polygon.count
    var centerX: CGFloat = 0
    var centerY: CGFloat = 0
    var area = signedPolygonArea(polygon: polygon)
    for i in 0 ..< nr {
        let j = (i + 1) % nr
        let factor1 = polygon[i].x * polygon[j].y - polygon[j].x * polygon[i].y
        centerX = centerX + (polygon[i].x + polygon[j].x) * factor1
        centerY = centerY + (polygon[i].y + polygon[j].y) * factor1
    }
    area = area * 6.0
    let factor2 = 1.0/area
    centerX = centerX * factor2
    centerY = centerY * factor2
    let center = CGPoint.init(x: centerX, y: centerY)
    return center
}


struct MapView: UIViewRepresentable {
  private let mapView: MGLMapView = MGLMapView(frame: .zero, styleURL: MGLStyle.streetsStyleURL)

  func makeUIView(context: UIViewRepresentableContext<MapView>) -> MGLMapView {
    mapView.logoView.isHidden = true
    mapView.attributionButton.isHidden = true
    mapView.delegate = context.coordinator

    return mapView
  }

  func updateUIView(_: MGLMapView, context _: UIViewRepresentableContext<MapView>) {}

  func makeCoordinator() -> MapView.Coordinator {
    Coordinator(self)
  }

  final class Coordinator: NSObject, MGLMapViewDelegate {
    var control: MapView
    var filterUpdate: AnyCancellable?
    var colorUpdate: AnyCancellable?
    var layer: MGLFillStyleLayer?
    var bgLayer: MGLBackgroundStyleLayer?
    var labelLayer: MGLSymbolStyleLayer?

    @Injected var filterState: FilterState
    @Injected var colorAndDataState: ColorAndDataState

    init(_ control: MapView) {
      self.control = control
    }

    func update() {
      guard let layer = layer else {
        return
      }
      
      
      let conditions = colorAndDataState.countryColors
        .map { key, value in (NSExpression(forConstantValue: key), NSExpression(forConstantValue: value))
        }.reduce(into: [:]) { $0[$1.0] = $1.1 }

      if conditions.count > 0 {
        layer.fillColor = NSExpression(format: "TERNARY(ADM0_A3 IN %@, %@, %@)", filterState.countries.map { $0.id },
                                       NSExpression(forMGLMatchingKey:
                                         NSExpression(forKeyPath: "ADM0_A3"),
                                                    // NSExpression(format: "MGL_FUNCTION('get', 'ADM0_A3')"),
                                         in: conditions,
                                                    default: NSExpression(forConstantValue: colorAndDataState.colorTheme.lowValue)),
                                       colorAndDataState.colorTheme.filtered)
      } else {
        layer.fillColor = NSExpression(format: "TERNARY(ADM0_A3 IN %@, %@, %@)", filterState.countries.map { $0.id },
                                       colorAndDataState.colorTheme.lowValue, colorAndDataState.colorTheme.filtered)
      }

      if !colorAndDataState.showFiltered {
        layer.fillOpacity = NSExpression(format: "TERNARY(ADM0_A3 IN %@, 1, 0)", filterState.countries.map { $0.id })
      } else {
        layer.fillOpacity = NSExpression(forConstantValue: 1)
      }

      guard let bgLayer = bgLayer else {
        return
      }

      bgLayer.backgroundColor = NSExpression(forConstantValue: colorAndDataState.colorTheme.background)
    }

    func mapView(_: MGLMapView, didFinishLoading style: MGLStyle) {
      guard let url = Bundle.main.url(forResource: "ne_10m_admin_0_countries", withExtension: "json") else {
        fatalError("Failed to locate 'ne_10m_admin_0_countries.geo' in bundle.")
      }

      if filterUpdate == nil {
        print("Registering filter update sink")
        filterUpdate = filterState.countriesDidChange.receive(on: RunLoop.main).sink {
          self.update()
        }
      }

      if colorUpdate == nil {
        print("Registering color update sink")
        colorUpdate = colorAndDataState.stateDidChange.receive(on: RunLoop.main).sink {
          self.update()
        }
      }

      style.layers = []
      
      let data = try! Data(contentsOf: url)
      let countriesFeatures = try! MGLShape(data: data, encoding: String.Encoding.utf8.rawValue) as! MGLShapeCollectionFeature

      let countries: MGLShapeSource = MGLShapeSource(identifier: "countries", shape: countriesFeatures)

      let bgLayer = MGLBackgroundStyleLayer(identifier: "background")
      bgLayer.backgroundColor = NSExpression(forConstantValue: colorAndDataState.colorTheme.background)

      style.addLayer(bgLayer)
      self.bgLayer = bgLayer

      let newLayer = MGLFillStyleLayer(identifier: "countries", source: countries)
      newLayer.sourceLayerIdentifier = "countries"

      style.addLayer(newLayer)
      layer = newLayer
      style.addSource(countries)
      
      var pointFeatures: [MGLPointFeature] = []
      
    
      for feature in countriesFeatures.shapes {
        switch feature {
        case let multiPolyFeature as MGLMultiPolygonFeature:
      
          
          for polygon in multiPolyFeature.polygons {
            
              let pointFeature = MGLPointFeature()
                    var polyCoords: [CLLocationCoordinate2D] = []
              
              let coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: Int(polygon.pointCount))
              polygon.getCoordinates(coordsPointer, range: NSMakeRange(0, Int(polygon.pointCount)))
              
              
              for i in 0..<polygon.pointCount {
                  polyCoords.append(coordsPointer[Int(i)])
              }
            
            let point = polygonCenterOfMass(polygon: polyCoords.map { CGPoint(x: $0.longitude, y: $0.latitude)})
                         
                         pointFeature.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(point.y), longitude: CLLocationDegrees(point.x))
                         
                         pointFeature.title = "Bar"
                         // A feature’s attributes can used by runtime styling for things like text labels.
                         pointFeature.attributes = [
                           "name": feature.attribute(forKey: "ADM0_A3") ?? "NONE"
                         ]
                        
                         pointFeatures.append(pointFeature)
          }
              
             
            
        case let polygon as MGLPolygonFeature:
          
         
            let pointFeature = MGLPointFeature()
            
            let coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: Int(polygon.pointCount))
            polygon.getCoordinates(coordsPointer, range: NSMakeRange(0, Int(polygon.pointCount)))
            
            var polyCoords: [CLLocationCoordinate2D] = []
            for i in 0..<polygon.pointCount {
                polyCoords.append(coordsPointer[Int(i)])
            }
            
            let point = polygonCenterOfMass(polygon: polyCoords.map { CGPoint(x: $0.longitude, y: $0.latitude)})
            
            pointFeature.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(point.y), longitude: CLLocationDegrees(point.x))
            
            pointFeature.title = "Bar"
            // A feature’s attributes can used by runtime styling for things like text labels.
            pointFeature.attributes = [
              "name": feature.attribute(forKey: "ADM0_A3")  ?? "NONE"
            ]
           
            pointFeatures.append(pointFeature)
      
          default:
          print(feature)

          }
      }
  
      
      let pois: MGLShapeSource = MGLShapeSource(identifier: "pois", features: pointFeatures)
      
      let labelLayer = MGLSymbolStyleLayer(identifier: "coffeeshops", source: pois)
      labelLayer.sourceLayerIdentifier = "pois"
//      labelLayer.iconImageName = NSExpression(forConstantValue: "coffee")
//      labelLayer.iconScale = NSExpression(forConstantValue: 0.5)
      labelLayer.text = NSExpression(forKeyPath: "name")
      labelLayer.textColor = NSExpression(forConstantValue: UIColor.white)
             labelLayer.textFontSize = NSExpression(forConstantValue: NSNumber(value: 16))
             labelLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
//      labelLayer.textFontSize = NSExpression(forConstantValue: 16)
//      labelLayer.textFontNames = NSExpression(forConstantValue: ["Trebuchet MS"])
//      labelLayer.textTranslation = NSExpression(forConstantValue: NSValue(cgVector: CGVector(dx: 10, dy: 0)))
//      labelLayer.textJustification = NSExpression(forConstantValue: "left")
//      labelLayer.textAnchor = NSExpression(forConstantValue: "left")
//      labelLayer.predicate = NSPredicate(format: "name == Foo")
      style.addSource(pois)
      style.addLayer(labelLayer)
      
      self.labelLayer = labelLayer
    
      update()
    }
  }
}
