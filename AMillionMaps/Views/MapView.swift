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
    var colorUpdate: AnyCancellable?
    var layer: MGLFillStyleLayer?
    var bgLayer: MGLBackgroundStyleLayer?

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

      let countries: MGLShapeSource = MGLShapeSource(identifier: "countries", url: url)

      let bgLayer = MGLBackgroundStyleLayer(identifier: "background")
      bgLayer.backgroundColor = NSExpression(forConstantValue: colorAndDataState.colorTheme.background)

      style.addLayer(bgLayer)
      self.bgLayer = bgLayer

      let newLayer = MGLFillStyleLayer(identifier: "countries", source: countries)
      newLayer.sourceLayerIdentifier = "countries"

      style.addLayer(newLayer)
      layer = newLayer
      style.addSource(countries)
      update()
    }
  }
}
