
from rich import print
from rich.progress import track

from shapely.errors import TopologicalError
from shapely.geometry import MultiPolygon, Polygon
from shapely.algorithms.polylabel import polylabel
import geopandas as gpd

from functools import partial
from math import sqrt
import pyproj
from shapely.ops import transform

src = pyproj.Proj('epsg:4326')
tgt = pyproj.Proj('epsg:3857')

project = partial(pyproj.transform, src, tgt)
inv_project = partial(pyproj.transform, tgt, src)


def to_label_point(geom: Polygon):
    # geom = transform(project, geom)  # apply projection
    result_geom = polylabel(geom)
    # result_geom = transform(inv_project, result_geom)
    return result_geom

def label_points():
    
    countries = gpd.read_file('../AMillionMaps/ne_10m_admin_0_countries.json')

    label_features = []
    labeld_ids = []

    scaleranks = []
    labelranks = []
    minlabels = []
    maxlabels = []

    rows = list(countries.iterrows())
    for idx, country in track(rows):
        country_features = country["geometry"]
        country_id = country["ADM0_A3"]
    
        scalerank = country["scalerank"]
        labelrank = country["LABELRANK"]
        minlabel = country["MIN_LABEL"]
        maxlabel = country["MAX_LABEL"]

        print(country_id)

        labelable_candidates = []
        largest_area = 0

        if isinstance(country_features, MultiPolygon):
            candidates = country_features.geoms
            candidates = sorted(candidates, key=lambda g: g.area, reverse=True)

            print(f"Sorted {len(candidates)} features")

            largest_area = max([g.area for g in candidates])

            for feature in candidates:
                if feature.area < 0.01 * largest_area:
                    continue
                try:
                    label_feature = to_label_point(feature)
                    labelable_candidates.append((label_feature, feature))
                except TopologicalError:
                    pass
            
        else:
            try:
                labelable_candidates.append((to_label_point(country_features), country_features))
            except TopologicalError:
                pass

        print(f"Found {len(labelable_candidates)} label candidates.")

        if labelable_candidates:

            major_candidate = labelable_candidates[0]
            secondary_candidates = labelable_candidates[1:]

            label_features.append(major_candidate[0])
            labeld_ids.append(country_id)
            scaleranks.append(scalerank)
            labelranks.append(labelrank)
            minlabels.append(minlabel)
            maxlabels.append(maxlabel)

            for label_feature, country_feature in secondary_candidates:
                if country_feature.area > 0.5 * largest_area or \
                    label_feature.distance(major_candidate[1]) > sqrt(largest_area):

                    label_features.append(label_feature)
                    labeld_ids.append(country_id)
                    scaleranks.append(scalerank)
                    labelranks.append(labelrank)
                    minlabels.append(minlabel)
                    maxlabels.append(maxlabel)
        else:
            print(f"Could not label {country_id}")
    
    df = gpd.GeoDataFrame(data={"ADM0_A3": labeld_ids, "scalerank": scaleranks, "labelrank": labelranks, "minlabel": minlabels, "maxlabel": maxlabels, "geometry": label_features})

    df = df.sort_values(by=["scalerank", "labelrank", "minlabel"])

    df.to_file("../AMillionMaps/labels.geojson", driver='GeoJSON')

label_points()