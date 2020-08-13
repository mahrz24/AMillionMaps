from sqlalchemy import *
from enum import Enum

metadata = MetaData()

class CountryType(Enum):
    sovereign = 0
    autonomous = 1
    dependent_territory = 2
    other = 3

country = Table('country', metadata,
    Column('country_id', String(3), primary_key=True),
    Column('country_name', String(256)),
    Column('country_type', Float),
    Column('country_population', Float),
    Column('country_area', Float)
)