# -*- coding: utf-8 -*-
"""
Created on Fri Dec 29 12:48:24 2023

@author: sse6
"""
import pandas as pd
from sqlalchemy.engine import URL 
from sqlalchemy import create_engine 

connection_string = ("Driver={ODBC Driver 17 for SQL Server};" 
            "Server= DSDV-INFC-1900.cdc.gov;" 
            "Database=NCBDDD_MATLINK;" 
            "Trusted_Connection=yes;") 

connection_url = URL.create("mssql+pyodbc", query={"odbc_connect": connection_string}) 
engine = create_engine(connection_url) 
MAT = pd.read_sql("SELECT top (10)* from tier1.IDTesting ", engine) 





import pyodbc
connection_string = pyodbc.connect(
            'DRIVER={ODBC Driver 17 for SQL Server};'
            "Server= DSDV-INFC-1900.cdc.gov;" 
            "Database=NCBDDD_MATLINK;" 
            "Trusted_Connection=yes;") 

select_string = "select top (10) * from [NCBDDD_MATLINK].[tier1].[IDTesting]"
df = pd.read_sql(select_string, connection_string )

 
