
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import MetaData

# Make sure we use dbo schema in SQL Server to match existing tables
metadata = MetaData(schema="dbo")
db = SQLAlchemy(metadata=metadata)
