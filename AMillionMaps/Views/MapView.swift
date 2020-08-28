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
    var colorAndDataUpdate: AnyCancellable?
    var layer: MGLFillStyleLayer?
    var bgLayer: MGLBackgroundStyleLayer?
    var labelLayer: MGLSymbolStyleLayer?

    @Injected var filterState: FilterState
    @Injected var colorAndDataState: ColorAndDataState

    init(_ control: MapView) {
      self.control = control
    }

    func update() {
      guard let layer = layer, let labelLayer = labelLayer else {
        return
      }

      let conditions = colorAndDataState.countryColors
        .map { key, value in (NSExpression(forConstantValue: key), NSExpression(forConstantValue: value))
        }.reduce(into: [:]) { $0[$1.0] = $1.1 }

      if conditions.count > 0 {
        layer.fillColor = NSExpression(format: "TERNARY(ADM0_A3 IN %@, %@, %@)", filterState.countries.map { $0.id },
                                       NSExpression(forMGLMatchingKey:
                                         NSExpression(forKeyPath: "ADM0_A3"),
                                                    in: conditions,
                                                    default: NSExpression(forConstantValue: colorAndDataState.colorTheme.mapLowValue)),
                                       colorAndDataState.colorTheme.mapFiltered)
      } else {
        layer.fillColor = NSExpression(format: "TERNARY(ADM0_A3 IN %@, %@, %@)", filterState.countries.map { $0.id },
                                       colorAndDataState.colorTheme.mapLowValue, colorAndDataState.colorTheme.mapFiltered)
      }

      let labelConditions = colorAndDataState.countryLabels
        .map { key, value in (NSExpression(forConstantValue: key), NSExpression(forConstantValue: value))
        }.reduce(into: [:]) { $0[$1.0] = $1.1 }

      if labelConditions.count > 0 {
        labelLayer.text = NSExpression(forMGLMatchingKey:
          NSExpression(forKeyPath: "ADM0_A3"),
                                       in: labelConditions,
                                       default: NSExpression(forConstantValue: ""))
      }

      // TODO: cache expressions?

      var stops: [Double: NSExpression] = [:]

      if !colorAndDataState.showFiltered {
        layer.fillOpacity = NSExpression(format: "TERNARY(ADM0_A3 IN %@, 1, 0)", filterState.countries.map { $0.id })

        for zoomLevel in stride(from: 0, to: 20, by: 0.25) {
          let val = Double(zoomLevel)
          let expr = NSExpression(format: "TERNARY(%f > (minlabel-2), %@, 0)", val,
                                  NSExpression(format: "TERNARY(ADM0_A3 IN %@, 1, 0)", filterState.countries.map { $0.id }))
          stops[zoomLevel] = expr
        }

      } else {
        layer.fillOpacity = NSExpression(forConstantValue: 1)

        for zoomLevel in stride(from: 0, to: 20, by: 0.25) {
          let val = Double(zoomLevel)
          let expr = NSExpression(format: "TERNARY(%f > (minlabel-2), 1, 0)", val)
          stops[zoomLevel] = expr
        }
      }

      labelLayer.textOpacity = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', 0, %@)", stops)

      guard let bgLayer = bgLayer else {
        return
      }

      bgLayer.backgroundColor = NSExpression(forConstantValue: colorAndDataState.colorTheme.mapBackground)
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

      if colorAndDataUpdate == nil {
        print("Registering color update sink")
        colorAndDataUpdate = colorAndDataState.stateDidChange.receive(on: RunLoop.main).sink {
          self.update()
        }
      }

      style.layers = []

      let data = try! Data(contentsOf: url)
      let countriesFeatures = try! MGLShape(data: data, encoding: String.Encoding.utf8.rawValue) as! MGLShapeCollectionFeature

      let countries: MGLShapeSource = MGLShapeSource(identifier: "countries", shape: countriesFeatures)

      let bgLayer = MGLBackgroundStyleLayer(identifier: "background")
      bgLayer.backgroundColor = NSExpression(forConstantValue: colorAndDataState.colorTheme.mapBackground)

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
      labelLayer.textColor = NSExpression(forConstantValue: UIColor.black)
      labelLayer.textFontSize = NSExpression(forConstantValue: NSNumber(value: 12))

      style.addSource(labels)
      style.addLayer(labelLayer)

      self.labelLayer = labelLayer

      update()
    }
  }
}
