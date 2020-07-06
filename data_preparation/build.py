from sqlalchemy import create_engine
from sqlalchemy import insert
from devtools import debug

from .schema import metadata, country
import requests
import bs4
import json

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
    for countries_url in countries_urls:
        countries_data = scrape_countries_details(BASE_URL + countries_url)
        all_countries_details.extend(countries_data)

    debug(all_countries_details)

    with open("country_code_data.json", "w") as output_file:
        json.dump(all_countries_details, output_file)



def fetch_population():
    response = requests.get("https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population")
    soup = bs4.BeautifulSoup(response.text, "html.parser")

    table = soup.find("table", {"class": "wikitable sortable"})
    rows = table.findAll("tr")

    all_countries_population = []
    
    for row in rows:
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

def create_db():
    engine = create_engine(f"sqlite:///countries.db")
    metadata.create_all(engine)


def insert_country_codes_to_db():
    engine = create_engine(f"sqlite:///countries.db")
    
    with open("country_code_data.json", "r") as input_file:
        all_countries_details = json.load(input_file)

    with engine.connect() as connection:
        for ctry in all_countries_details:
            i = country.insert().values({"country_id": ctry["ISO 3166-1 alpha-3"], "country_name": ctry["country_name"]})
            connection.execute(i)


def insert_population_to_db():
    engine = create_engine(f"sqlite:///countries.db")
    
    with open("country_population_data.json", "r") as input_file:
        all_countries_population = json.load(input_file)

    with engine.connect() as connection:
        for ctry in all_countries_population:
            i = country.update().values({"country_population": ctry["country_population"]}).where(country.c.country_name == ctry["country_name"])
            connection.execute(i)

def build():
    fetch_country_codes()
    fetch_population()

    create_db()
    insert_country_codes_to_db()
    insert_population_to_db()

if __file__ == "__main__":
    build()