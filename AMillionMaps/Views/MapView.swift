//
//  MapView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 30.06.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation

import Mapbox
import SwiftUI
import Resolver
import Combine

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
    var countryUpdate: AnyCancellable? = nil
    var layer: MGLFillStyleLayer? = nil
    @Injected var filteredCountryProvider: StatefulFilteredCountryProvider

    init(_ control: MapView) {
      self.control = control
    }
    
    func update() {
      self.layer?.fillColor = NSExpression(format: "TERNARY(ADM0_A3 IN %@, %@, %@)", self.filteredCountryProvider.countries.map { $0.id }, UIColor.darkGray, UIColor.systemPink)
      //self.layer?.fillOpacity = NSExpression(format: "TERNARY(ADM0_A3 IN %@, 1, 0.2)", self.filteredCountryProvider.countries.map { $0.id })
    }

    func mapView(_: MGLMapView, didFinishLoading style: MGLStyle) {
      
      guard let url = Bundle.main.url(forResource: "ne_10m_admin_0_countries", withExtension: "json") else {
        fatalError("Failed to locate 'ne_10m_admin_0_countries.geo' in bundle.")
      }

      if countryUpdate == nil {
        print("Registering update sink")
           countryUpdate = filteredCountryProvider.countriesDidChange.receive(on: RunLoop.main).sink {
             self.update()
           }
         }
      
      style.layers = []

      let countries: MGLShapeSource = MGLShapeSource(identifier: "countries", url: url)

      let newLayer = MGLFillStyleLayer(identifier: "countries", source: countries)
      newLayer.sourceLayerIdentifier = "countries"
      
      newLayer.fillColor = NSExpression(format: "TERNARY(ADM0_A3 IN %@, %@, %@)", self.filteredCountryProvider.countries.map { $0.id }, UIColor.darkGray, UIColor.systemPink)
      //newLayer.fillOpacity = NSExpression(format: "TERNARY(ADM0_A3 IN %@, 1, 0.2)", self.filteredCountryProvider.countries.map { $0.id })
      style.addLayer(newLayer)
      layer = newLayer

      style.addSource(countries)
    }
  }
}
