from sqlalchemy import *

metadata = MetaData()

country = Table('country', metadata,
    Column('country_id', String(3), primary_key=True),
    Column('country_name', String(256)),
    Column('country_population', Integer),
    Column('country_area', Integer)
)