import pyodbc
import pandas as pd

class Connection:
	def __init__(self, server, database):
		self.server = server
		self.database = database
		self.cnxn = self.connect()

	def connect(self):
		cnxn = pyodbc.connect('Trusted_Connection=Yes;DRIVER={ODBC Driver 17 for SQL Server};SERVER='+self.server+';DATABASE='+self.database)	
		print('Connection to {} established on {}'.format(self.database,self.server))
		return cnxn

	def pandize_data(self, query, string = False):
		if not string:
			path = query+'.sql'
			with open(path, 'r') as file:
				sql = file.read()
		else:
			sql = query
		return pd.read_sql_query(sql,self.cnxn)