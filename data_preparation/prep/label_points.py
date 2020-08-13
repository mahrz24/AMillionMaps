
from rich import print
from rich.progress import track

import json
from shapely.geometry import mapping, shape, MultiPolygon, Polygon
from shapely.algorithms.polylabel import polylabel
import geopandas as gpd
import geojsonio
import pandas as pd

def to_label_point(geom: Polygon):
    return polylabel(geom)

def label_points():
    
    countries = gpd.read_file('../AMillionMaps/ne_10m_admin_0_countries.json')

    label_features = []
    rows = list(countries.iterrows())
    for idx, country in track(rows):
        country_features = country["geometry"]

        if isinstance(country_features, MultiPolygon):
            for feature in country_features.geoms:
                label_features.append(to_label_point(feature))
        else:
            label_features.append(to_label_point(country_features))
    
    df = gpd.GeoDataFrame(data={"geometry": label_features})

    with open("out.json", "w") as f:
        f.write(df.to_json())

label_points()