import code
from sqlGetter import Connection
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime

hrdcdb = Connection('ARES-IV\\SQLEXPRESS','HRDC09_Prod')


def import_om_data():
	om = hrdcdb.pandize_data('OM_Scores')
	# print(om.info())
	# clients = list(set(list(om.EntityID)))
	om.Date = pd.to_datetime(om.Date, errors = 'coerce')

	om.set_index(['Date'], inplace = True)

	om = om.loc['2010-01-01':'2021-12-31']

	domains = ['Education'
				, 'Employment'
				, 'Housing'
				, 'Income'
				, 'Transportation'
				, 'Childcare'
				, 'Food Security'
				, 'Health Care/Services'
				, 'Nutrition'
				, 'Financial Literacy']

	om = om[om.Domain.isin(domains)]
	return om

def import_service_data():
	services = hrdcdb.pandize_data('Services')
	services.Date = pd.to_datetime(services.Date, errors = 'coerce')
	services.set_index(['Date'], inplace = True)
	services = services.loc['2010-01-01':'2021-12-31']
	services.to_csv('services.csv')
	return services



# for d in domains:
# 	domain = om[om.Domain == d]
# 	axes = domain.Score.resample('M').mean().plot()
# 	axes.set_title(d)
# 	plt.show()
# edu = om[om.Domain == 'Education']

# services = hrdcdb.pandize_data('Services')
# print(services.info())



# Find changes in scores over time
def calculate_deltas(om):
	start_time = datetime.now()
	print(f'Start time: {start_time}')
	diff_list = []
	for e in om.EntityID.unique():
		client_data = om[om.EntityID == e]
		for d in domains:
			domain_data = client_data[client_data.Domain == d]
			diffs = domain_data.Score.diff()
			# code.interact(local = locals())
			delta = diffs.rename('Delta')
			diff_data = pd.DataFrame.from_dict(delta)
			diff_data['Score'] = domain_data.Score
			diff_data['Domain'] = d
			diff_data['EntityID'] = e
			diff_data['Program'] = domain_data['Program Collecting Score']
			diff_data['date_index'] = diff_data.index
			diff_data['LastScoreDate'] = diff_data.date_index.shift()
			diff_data.drop(labels = 'date_index', axis = 1)
			diff_list.append(diff_data)
	final_data = pd.concat(diff_list)
	end_time = datetime.now()
	print(f'End time: {end_time}\nTime elapsed: {end_time - start_time}')
	final_data.to_csv('om_deltas.csv')
	return final_data

def calculate_client_deltas(df):
	# print(df.iloc[0].EntityID)
	return df.groupby('Domain').apply(func = calculate_domain_deltas)

def calculate_domain_deltas(df):
	# print(df.iloc[0].Domain)
	# print(df)
	try:
		delta = df.Score.diff().rename('Delta')
		# df['date_index'] = df.index
		df = df.reset_index()
		df['LastScoreDate'] = df.Date.shift()
		delta = delta.reset_index()
		df = pd.concat([df, delta], axis = 1)
	except ValueError:
		code.interact(local = locals())
	return df

def pivot_domains(df):
	# print(df)
	try:
		scores = df.pivot(index = 'date_index', columns = 'Domain', values = 'Score')
		deltas = df.pivot(index = 'date_index', columns = 'Domain', values = 'Delta')
		deltas.columns = deltas.columns.values + '_d'
		combined = pd.merge(scores, deltas, left_index = True, right_index = True)
	except ValueError:
		return None
	return combined

def speed_test(raw):
	start_time = datetime.now()
	deltas = raw.groupby('EntityID').apply(func = calculate_client_deltas)
	# result = deltas.groupby('EntityID').apply(func = pivot_domains)
	end_time = datetime.now()
	print(f'Time elapsed: {end_time - start_time}')
	return deltas


# data = calculate_deltas(om)
om = import_om_data()
df = speed_test(om)
code.interact(local = locals())