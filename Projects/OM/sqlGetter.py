import pyodbc
import pandas as pd

# server = 'HRDCL-HD002\\SQLEXPRESS' 
# server = 'ARES-IV\\SQLEXPRESS'
# database = 'HRDC09_Prod'

# def connect(server, database):
# 	cnxn = pyodbc.connect('Trusted_Connection=Yes;DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+database)	
# 	print('Connection to {} established on {}'.format(database,server))
# 	return cnxn	

# def pandize_data(query):
# 	path = query+'.sql'
# 	with open(path, 'r') as file:
# 		sql = file.read()
# 	return pd.read_sql_query(sql,cnxn)

# cnxn = connect(server, database)

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