import numpy as np
from sqlGetter import *

# Get list of first/last name pairs

services = pd.read_excel('services.xlsx', sheet_name = 'Data Entry')
services = services[services['First Name'] != 'Anon']
indirect_services = services[services['Anon'] == 'y']
# print(services.info())


# Search database for rows matching
def name_search(first_name, last_name):
	with open('qu.sql', 'r') as file:
		sql = file.read()
	try:
		first_name = first_name.replace('\'','\'\'')
		last_name = last_name.replace('\'','\'\'')
	except AttributeError:
		return 'bad data'

	sql = sql.replace('*FIRST NAME*', first_name)
	sql = sql.replace('*LAST NAME*', last_name)

	return pd.read_sql_query(sql,cnxn)


def enrollment_id(data):
	#use pandize data to get enrollment IDs
	with open('enrollments.sql', 'r') as file:
		sql = file.read()

	sql = sql.replace('**Entity ID**',str(int(data)))

	return pd.read_sql_query(sql,cnxn)
	

# go through the data and create a new service record for each row
def generate_sql(data):
	with open('bulkinsert.sql', 'a') as file:
		for index, row in data.iterrows():
			# print(row['First Name'])
			ServiceTypeID = '636'
			# print(ServiceTypeID)
			ProvidedToEntityID = row['EntityID']
			# print(ProvidedToEntityID)
			ProvidedByEntityID = '58357'
			# print(ProvidedByEntityID)
			EnrollmentID = row['EnrollmentID']
			# print(EnrollmentID)
			UnitOfMeasure = '109'
			UnitValue = '1'
			if pd.isnull(row['# inHH']):
				Units = ServiceTotal = 1
				# print(Units)
			else:
				Units = ServiceTotal = row['# inHH']
				# print(Units)
			BeginDate = '\'11/22/2020\''
			EndDate = '\'11/22/2020\''
			CreatedBy = '58357'
			OwnedByOrgID = '4196'
			AccountID = '140'
			line = '\t('+ServiceTypeID+', '+str(int(ProvidedToEntityID))+', '+ProvidedByEntityID+', '+str(int(EnrollmentID))+', '+UnitOfMeasure+', '+UnitValue+', '+str(int(Units))+', '+str(int(ServiceTotal))+', '+BeginDate+', '+EndDate+', '+CreatedBy+', '+OwnedByOrgID+', '+AccountID+'),\n'
			# print(line)
			file.write(line)

# lookup = name_search('Peter', 'Asmuth')
# print(lookup.iloc[0]['EntityID'])

def create_indirect_service(data):
	with open('bulkinsert.sql', 'a') as file:
		for index, row in data.iterrows():
			# print(row['First Name'])
			ServiceTypeID = '636'
			# print(ServiceTypeID)
			ProvidedToEntityID = '3'
			# print(ProvidedToEntityID)
			ProvidedByEntityID = '58357'
			# print(ProvidedByEntityID)
			EnrollmentID = '116933'
			# print(EnrollmentID)
			UnitOfMeasure = '109'
			UnitValue = '1'
			if pd.isnull(row['# inHH']):
				Units = ServiceTotal = 1
				# print(Units)
			else:
				Units = ServiceTotal = row['# inHH']
				# print(Units)
			BeginDate = '\'11/22/2020\''
			EndDate = '\'11/22/2020\''
			CreatedBy = '58357'
			OwnedByOrgID = '4196'
			AccountID = '140'
			line = '\t('+ServiceTypeID+', '+str(int(ProvidedToEntityID))+', '+ProvidedByEntityID+', '+str(int(EnrollmentID))+', '+UnitOfMeasure+', '+UnitValue+', '+str(int(Units))+', '+str(int(ServiceTotal))+', '+BeginDate+', '+EndDate+', '+CreatedBy+', '+OwnedByOrgID+', '+AccountID+'),\n'
			# print(line)
			file.write(line)


def create_script():
	services['EntityID'] = np.nan
	services['Matches'] = np.nan
	services['EnrollmentID'] = np.nan
	multiple_matches = pd.DataFrame()
	for index, row in services.iterrows():
		try:
			lookup = name_search(row['First Name'], row['Last Name'])
			services.at[index, 'EntityID'] = lookup.iloc[0]['EntityID']
			services.at[index, 'Matches'] = len(lookup)
			# print('here')
			if len(lookup) > 1:
				# print('and here')
				multiple_matches = multiple_matches.append(lookup, ignore_index = True)
		except AttributeError:
			pass
		except IndexError:
			services.at[index, 'Matches'] = 0
		except TypeError:
			pass

	# print(services.info())
	# services.to_csv('reverselookup.csv')

	good_match = services[services['Matches'] == 1] # 633 hard matches

	for index, row in good_match.iterrows():
		try:
			good_match.at[index, 'EnrollmentID'] = str(int(enrollment_id(row['EntityID']).iloc[0]['EnrollmentID']))
		except IndexError:
			pass

	better_match = good_match[good_match['EnrollmentID'].notnull()]
	print(better_match.info())


	generate_sql(better_match)
	create_indirect_service(indirect_services)

# bad_match = services[services['Matches'] > 1] # 32 multiple matches
# no_match = services[services['Matches'] == 0] # 341 no matches


# multiple_matches.to_csv('multiple matches.csv')
# good_match.to_csv('good matches.csv')
# bad_match.to_csv('bad matches.csv')
# no_match.to_csv('no matches.csv')

create_script()





