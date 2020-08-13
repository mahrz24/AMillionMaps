from sqlalchemy import create_engine
from devtools import debug

from rich import print
from rich.progress import track

from .schema import metadata, country, CountryType

import requests
import bs4
import json
import shutil
import os

BASE_URL = "https://en.wikipedia.org"
COUNTRY_CODES_URL = BASE_URL + "/wiki/Country_code"

def scrape_countries_details(url):
    # Get remote page
    response = requests.get(url)

    # Create soup object from page content
    soup = bs4.BeautifulSoup(response.text, "html.parser")

    countries_data = []

    # Fetch all elements that holds country name
    country_names_elems = soup.findAll('span', 'mw-headline')

    # For each country element retrieve all the relevant data
    for country_name_elem in country_names_elems:
        # Find the next table element after country name while holds
        # the country's data
        country_table = country_name_elem.parent.findNext("table")
        if not country_table:
            continue

        # Fetch all the cells in the table
        tds = country_table.findAll("td")

        # Each cell holds the column name and the value 
        # so we can create a dict by reading each cell
        # with the column name as the key and the cell data as the value
        country_data = {td.find("a").text: td.find("span").text for td in tds}

        # Add the country name and wikipedia page url for the country
        country_a_elem = country_name_elem.find('a')
        country_data["country_name"] = country_a_elem.text.replace("\n", "").strip()
        country_data["country_url"] = BASE_URL + country_a_elem['href']
        countries_data.append(country_data)
    return countries_data


def fetch_country_codes():
    response = requests.get(COUNTRY_CODES_URL)
    soup = bs4.BeautifulSoup(response.text, "html.parser")

    countries_urls = [a_elem['href'] for a_elem in soup.findAll('a') if a_elem.attrs.get('href', '').startswith('/wiki/Country_codes')]
    all_countries_details = []
    for countries_url in track(countries_urls):
        countries_data = scrape_countries_details(BASE_URL + countries_url)
        all_countries_details.extend(countries_data)

    with open("country_code_data.json", "w") as output_file:
        json.dump(all_countries_details, output_file)



def fetch_population():
    response = requests.get("https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population")
    soup = bs4.BeautifulSoup(response.text, "html.parser")

    table = soup.find("table", {"class": "wikitable sortable"})
    rows = table.findAll("tr")

    all_countries_population = []
    
    for row in track(rows):
        cells = row.findAll("td")
        if len(cells) > 2:
            links = cells[0].findAll('a')
            if links:
                country_name = links[0].text
                if not country_name:
                    country_name = links[1].text
                all_countries_population.append({
                    "country_name": country_name,
                    "country_population": int(cells[1].find(text=True).replace(",", ""))
                })

    with open("country_population_data.json", "w") as output_file:
        json.dump(all_countries_population, output_file)


def fetch_area():
    response = requests.get("https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_area")
    soup = bs4.BeautifulSoup(response.text, "html.parser")

    table = soup.find("table", {"class": "wikitable sortable"})
    rows = table.find("tbody").findAll("tr")

    all_countries_area = []

    for row in track(rows):
        cells = row.findAll("td")
        if len(cells) > 2:
            links = cells[1].findAll('a')
            if links:
                country_name = links[0].text
                if not country_name:
                    country_name = links[1].text
                all_countries_area.append({
                    "country_name": country_name.replace("The ", "").replace("State of ", ""),
                    "country_area": float(cells[2].find(text=True).split("(")[0].replace(",", "").replace("<", "").strip())
                })

    with open("country_area_data.json", "w") as output_file:
        json.dump(all_countries_area, output_file)


def create_db():
    #os.remove("countries.db")
    engine = create_engine(f"sqlite:///countries.db")
    metadata.create_all(engine)


def insert_country_codes_to_db():
    engine = create_engine(f"sqlite:///countries.db")
    
    with open("country_code_data.json", "r") as input_file:
        all_countries_details = json.load(input_file)

    with engine.connect() as connection:
        for ctry in track(all_countries_details):
            i = country.insert().values({"country_id": ctry["ISO 3166-1 alpha-3"], "country_name": ctry["country_name"]})
            connection.execute(i)


def insert_population_to_db():
    engine = create_engine(f"sqlite:///countries.db")
    
    with open("country_population_data.json", "r") as input_file:
        all_countries_population = json.load(input_file)

    with engine.connect() as connection:
        for ctry in track(all_countries_population):
            i = country.update().values({"country_population": ctry["country_population"]}).where(country.c.country_name == ctry["country_name"])
            connection.execute(i)

def insert_area_to_db():
    engine = create_engine(f"sqlite:///countries.db")
    
    with open("country_area_data.json", "r") as input_file:
        all_countries_area = json.load(input_file)

    with engine.connect() as connection:
        for ctry in track(all_countries_area):
            i = country.update().values({"country_area": ctry["country_area"]}).where(country.c.country_name == ctry["country_name"])
            connection.execute(i)

def extract_and_insert_sovereignty_to_db():
    engine = create_engine(f"sqlite:///countries.db")
    
    with open("../AMillionMaps/ne_10m_admin_0_countries.json", "r") as input_file:
        all_territories = json.load(input_file)["features"]

    with engine.connect() as connection:
        for ctry in track(all_territories):
            country_id = ctry["properties"]["ADM0_A3"]

            type_desc = ctry["properties"]["TYPE"]

            if type_desc == "Sovereign country":
                country_type = CountryType.sovereign
            elif type_desc == "Country":
                country_type = CountryType.autonomous
            elif type_desc == "Dependency":
                country_type = CountryType.dependent_territory
            else:
                country_type = CountryType.other

            i = country.update().values({"country_type": country_type.value}).where(country.c.country_id == country_id)
            connection.execute(i)

def build():
    # print(":world_map:  [magenta bold]Fetching country codes[/magenta bold]")
    # fetch_country_codes()
    # print(":chart_with_upwards_trend:  [magenta bold]Fetching population[/magenta bold]")
    # fetch_population()
    print(":world_map:  [magenta bold]Fetching area[/magenta bold]")
    fetch_area()

    print(":floppy_disk:  [magenta bold]Creating database[/magenta bold]")
    create_db()

    print(":floppy_disk:  [magenta bold]Inserting fetched data[/magenta bold]")
    insert_country_codes_to_db()
    insert_population_to_db()
    insert_area_to_db()

    print(":mag:  [magenta bold]Extracting and inserting sovereignty information[/magenta bold]")
    extract_and_insert_sovereignty_to_db()

build()