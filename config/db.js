# db.py
import os
import mysql.connector
from dotenv import load_dotenv

# Load environment variables from .env file (important for local testing)
load_dotenv()

# Create the database connection
connection = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME"),
    port=os.getenv("DB_PORT")
)
