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
        fatalError("Failed to locate 'ne_10m_admin_0_countries.geo.json' in bundle.")
      }
      
      guard let labelsUrl = Bundle.main.url(forResource: "labels", withExtension: "geojson") else {
        fatalError("Failed to locate 'labels.geojson' in bundle.")
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
      
      
      let labelData = try! Data(contentsOf: labelsUrl)
      let labelFeatures = try! MGLShape(data: labelData, encoding: String.Encoding.utf8.rawValue) as! MGLShapeCollectionFeature

      let labels: MGLShapeSource = MGLShapeSource(identifier: "labels", shape: labelFeatures)

      let labelLayer = MGLSymbolStyleLayer(identifier: "labels", source: labels)
      labelLayer.sourceLayerIdentifier = "labels"
      labelLayer.text = NSExpression(forKeyPath: "ADM0_A3")
      labelLayer.textColor = NSExpression(forConstantValue: UIColor.black)
      labelLayer.textFontSize = NSExpression(forConstantValue: NSNumber(value: 12))

      style.addSource(labels)
      style.addLayer(labelLayer)
      
      
      self.labelLayer = labelLayer
    
      update()
    }
  }
}
