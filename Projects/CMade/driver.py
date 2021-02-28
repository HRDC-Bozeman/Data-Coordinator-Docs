import re
import os
import time
import datetime
import pandas as pd
import numpy as np
import gspread
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException, TimeoutException, UnexpectedAlertPresentException
from selenium.webdriver.support.ui import WebDriverWait, Select
from selenium.webdriver.support import expected_conditions as EC
from oauth2client.service_account import ServiceAccountCredentials
from sqlGetter import *



def initialize_gspread():
	scope = ['https://spreadsheets.google.com/feeds',
	         'https://www.googleapis.com/auth/drive']
	path = os.path.dirname(os.path.realpath(__file__))
	sheets_creds = ServiceAccountCredentials.from_json_keyfile_name('{}\\client_secret.json'.format(path), scope)
	client = gspread.authorize(sheets_creds)
	sh = client.open_by_key('Google Sheets ID here')
	ws = sh.worksheet('Form Responses 1')
	return ws


# Launches an IE driver and logs into CounselorMax
# Replace 'Your CounselorMax Username' and 'Your CounselorMax Password'
# Returns the driver object
def cmax_login():
	driver = webdriver.Ie()
	driver.get('https://counselormax.net/login.asp')
	driver.refresh()

	login = driver.find_element_by_name('txtUserName')
	pw = driver.find_element_by_name('txtUserPass')
	submit = driver.find_element_by_name('Submit')
	login.send_keys('Your CounselorMax Username')
	pw.send_keys('Your CounselorMax Password')
	submit.send_keys(Keys.RETURN)
	time.sleep(1)

	driver.refresh()

	login = driver.find_element_by_name('txtUserName')
	pw = driver.find_element_by_name('txtUserPass')
	submit = driver.find_element_by_name('Submit')
	login.send_keys('Your CounselorMax Username')
	pw.send_keys('Your CounselorMax Password')
	submit.send_keys(Keys.RETURN)
	time.sleep(1)

	alert = driver.switch_to.alert
	alert.accept()
	return driver


# 
def get_client_info(clientID):
	with open('clientdata.sql', 'r') as file:
		sql = file.read()

	sql = sql.replace('**ClientID**', str(clientID))

	raw = pd.read_sql_query(sql,cnxn)

	record = raw.to_dict(orient='records')[0]
	return record


def get_records(sheet):
	records = []
	row_num = 2
	for r in sheet.get_all_records():
		if r['Processed'] == 'FALSE' and r['Timestamp']:
			r['row_num'] = row_num
			records.append(r)
		row_num += 1
	return records


def add_appts():
	s = initialize_gspread()
	r = get_records(s)

	print('{} appointments found.'.format(len(r)))

	driver = cmax_login()

	for x in r:
		cw_data = get_client_info(x['CaseWorthy Client ID'])
		
		while True:
			print('Searching for {} {} in CounselorMax'.format(cw_data['FirstName'],cw_data['LastName']))
			try:
				driver.find_element_by_name('txtNameSearch').clear()
			except UnexpectedAlertPresentException:
				print('there\'s an alert, click it or something')

			driver.find_element_by_name('txtNameSearch').clear()
			driver.find_element_by_name('txtNameSearch').send_keys('{}, {}'.format(cw_data['LastName'],cw_data['FirstName']))
			driver.find_element_by_name('txtNameSearch').send_keys(Keys.RETURN)
			isin = input('Is this client in CounselorMax, and are you on their page (y/n)?: ')
			if isin == 'y':
				intake = input('Does this client have an active case (y/n)?: ')
				if intake == 'y':
					if x['Appointment Type'] in ['At Entry', 'During']:
						add_hud_appointment(driver, x, s)
						break
					elif x['Appointment Type'] == 'Exit':
						add_hud_appointment(driver, x, s)
						input('This is an exit appointment, do it by hand and press any key when finished')
						break
				elif intake == 'n':
					case = input('Create case (y/n)?: ')
					if case == 'y':
						confirm = fill_cmax_intake(driver, cw_data, x)
						if confirm:
							add_hud_appointment(driver, x, s)
							break
						else:
							break
			elif isin == 'n':
				create_cmax_client(driver, cw_data, x)
				fill_cmax_intake(driver, cw_data, x)
				add_hud_appointment(driver, x, s)
				break
	refresh = input('End of Records, pull records again?')
	if refresh == 'y':
		r = get_records(s)
		if len(r) == 0:
			print('No new records')
			break
		else:
			add_appts()
	else:
		print('Terminating Script')
		break


# Create CounselorMax appointment from Google Sheet data
def add_hud_appointment(driver, hud_data, sheet):

	print('Creating {} appointment for {}'.format(hud_data['DATE OF SERVICE:'], hud_data['First Name']))
	driver.switch_to.default_content()

	while True:
		try:
			driver.find_element_by_id('t0').click()
			driver.switch_to.frame(driver.find_element_by_id('objFntFrame'))
			driver.find_element_by_name('chkCalendar').click()
			driver.switch_to.frame(driver.find_element_by_name('fraCalendar'))
			break
		except NoSuchElementException:
			driver.find_element_by_id('t1').click()
			pass


	main = driver.window_handles[0]
	driver.find_element_by_id('date1').click()
	driver.find_element_by_name('chkAddEvent').click()

	while True:
		try:
			print('trying to find the new window')
			WebDriverWait(driver, 3).until(EC.number_of_windows_to_be(2))
			print('done waiting')
			print(driver.window_handles)
			new = driver.window_handles[1]
			driver.switch_to_window(new)
			driver.find_element_by_name('txtStartDate').clear()
			break
		except NoSuchElementException:
			print('something happened...')

	# Date and Time
	driver.find_element_by_name('txtStartDate').send_keys(hud_data['DATE OF SERVICE:'])

	driver.find_element_by_name('txtEndDate').clear()
	driver.find_element_by_name('txtEndDate').send_keys(hud_data['DATE OF SERVICE:'])

	driver.find_element_by_name('lstStartHour').send_keys('12')
	driver.find_element_by_name('lstStartMinute').send_keys('0')
	if hud_data['Counseling Time'] == 0.5:
		driver.find_element_by_name('lstEndHour').send_keys('12')
		driver.find_element_by_name('lstEndMinute').send_keys('3')
	elif hud_data['Counseling Time'] == 0.75:
		driver.find_element_by_name('lstEndHour').send_keys('12')
		driver.find_element_by_name('lstEndMinute').send_keys('4')
	elif hud_data['Counseling Time'] == 1.0:
		driver.find_element_by_name('lstEndHour').send_keys('1')
		driver.find_element_by_name('lstEndMinute').send_keys('0')
	elif hud_data['Counseling Time'] == 2.0:
		driver.find_element_by_name('lstEndHour').send_keys('2')
		driver.find_element_by_name('lstEndMinute').send_keys('0')

	select = Select(driver.find_element_by_name('lstStaffInits'))
	select.deselect_all()
	if hud_data['Email Address'].split('@')[0] == 'jhuey':
		select.select_by_value('31583')
	elif hud_data['Email Address'].split('@')[0] == 'astone':
		select.select_by_value('31583')
	elif hud_data['Email Address'].split('@')[0] == 'jburk':
		select.select_by_value('32548')
	elif hud_data['Email Address'].split('@')[0] == 'kmiller':
		select.select_by_visible_text('HDA')
	else:
		pass

	# Description
	driver.find_element_by_name('txtDescription').send_keys(hud_data['Service Log'])

	# Location
	driver.find_element_by_name('txtLocation').send_keys(hud_data['Appointment Location'])

	# Purpose
	p_select = Select(driver.find_element_by_name('lstHUDPurposes'))
	p_select.deselect_all
	if hud_data['Counseling Type'] == 'Seeking Shelter or Homeless Services (SSHS)':
		p_select.select_by_visible_text('Homeless Assistance')
	elif hud_data['Counseling Type'] == 'Rental Counseling (RC)':
		p_select.select_by_visible_text('Rental Topics')
	elif hud_data['Counseling Type (Exit)'] == 'Seeking Shelter or Homeless Services (SSHS)':
		p_select.select_by_visible_text('Homeless Assistance')
	elif hud_data['Counseling Type (Exit)'] == 'Rental Counseling (RC)':
		p_select.select_by_visible_text('Rental Topics')
	else:
		p_select.select_by_visible_text('Rental Topics')

	# HUD Activity
	# try:
	# 	driver.find_element_by_name('lstActivity_Type').select_by_value('15')
	# except NoSuchElementException:
	# 	print('Not HUD Activity')
	# 	pass

	# Resolution
	if hud_data['Impact and Scope'] == 'Resource Referral':
		driver.find_element_by_name('lstImpactScope').send_keys('Gained access to non-hous')
	elif hud_data['Impact and Scope'] == 'Budget Completed':
		driver.find_element_by_name('lstImpactScope').send_keys('Counselor dev')
	elif hud_data['Impact and Scope'] == 'Stabilized Housing with Assistance':
		driver.find_element_by_name('lstImpactScope').send_keys('Homeless')
	elif hud_data['Impact and Scope'] == 'Stabilized Housing without Financial Assistance':
		driver.find_element_by_name('lstImpactScope').send_keys('Received rental')
	elif 'Accessed Housing Resources' in hud_data['Impact and Scope']:
		driver.find_element_by_name('lstImpactScope').send_keys('Gained access to res')

	confirm = input('Confirm appointment (y/n)?: ')

	if confirm == 'y':
		print('Confirming...')
		driver.find_element_by_name('cmdOK').send_keys(Keys.RETURN)
		driver.switch_to_window(main)
		sheet.update_cell(hud_data['row_num'], 17, 'TRUE')
		try:
			# Close dialog boxes about new counselor
			pass
		except IndexError:
			# This means there were no dialog boxes
			pass

	elif confirm == 'n':
		print('Make needed changes and confirm (y), or exit without saving (n)')
		re_confirm = input('Confirm (y/n)?: ')
		if re_confirm == 'y':
			print('Confirming...')
			driver.find_element_by_name('cmdOK').send_keys(Keys.RETURN)
			driver.switch_to_window(main)
			sheet.update_cell(hud_data['row_num'], 17, 'TRUE')
		elif re_confirm == 'n':
			driver.close()
			print('Closing...')
			driver.switch_to_window(main)


def create_cmax_client(driver, demogs, appt):
	# Get to the main screen
	driver.find_element_by_name('cmdMode').send_keys(Keys.RETURN)

	# Click the new client button
	driver.find_element_by_name('chkNewClient').click()

	# Switch to inner frame
	driver.switch_to.frame(driver.find_element_by_id('objFntFrame'))
	driver.switch_to.frame(driver.find_elements_by_tag_name('iframe')[3])

	# Fill out the demographic information
	driver.find_element_by_name('txtFirst_Name').send_keys(demogs['FirstName'])
	driver.find_element_by_name('txtLast_Name').send_keys(demogs['LastName'])
	driver.find_element_by_name('txtMiddle_Name').send_keys(demogs['MiddleName'])
	driver.find_element_by_name('txtStreet_Address').send_keys(demogs['Address1'])
	driver.find_element_by_name('txtZip_Code').send_keys(demogs['ZipCode'])
	driver.find_element_by_name('txtPhone_Areacode_Other').send_keys(demogs['CellPhone'])
	driver.find_element_by_name('txtEMail_Addr').send_keys(demogs['Email'])
	if appt['Appointment Location'] == 'Housing First':
		driver.find_element_by_name('lstPurpose_ID').send_keys('hf')
	elif appt['Appointment Location'] == 'Housing Choice Voucher':
		driver.find_element_by_name('lstPurpose_ID').send_keys('s8')

	# Submit
	driver.find_element_by_name('cmdValidate').send_keys(Keys.RETURN)

	while True:
		try:
			WebDriverWait(driver, 3).until(EC.alert_is_present())
			alert = driver.switch_to.alert
			alert.accept()
			pass
		except TimeoutException:
			break


# Enter CounselorMax Housing First intake data
def fill_cmax_intake(driver, demogs, hud_data):
	
	driver.switch_to.default_content()
	search = driver.find_element_by_name('txtNameSearch')
	name = demogs['LastName'] + ', ' + demogs['FirstName']
	search.clear()
	search.send_keys(name)
	search.send_keys(Keys.RETURN)
	time.sleep(1)
	driver.find_element_by_id('t2').click()

	while True:
		try:
			WebDriverWait(driver, 3).until(EC.alert_is_present())
			alert = driver.switch_to.alert
			alert.accept()
			pass
		except TimeoutException:
			break

	driver.switch_to.frame(driver.find_element_by_id('objFntFrame'))
	driver.switch_to.frame(driver.find_elements_by_tag_name('iframe')[0])
	
	# Service Type
	if hud_data['Appointment Location'] == 'Housing First':
		driver.find_element_by_name('lstService_Type_ID').send_keys(hud_data['Counseling Type'][0])
	elif hud_data['Appointment Location'] == 'Housing Choice Voucher':
		driver.find_element_by_name('lstService_Type_ID').send_keys('r')
		driver.find_element_by_name('chkHUD_Activity').click()
		select = Select(driver.find_element_by_name('lstActivity_Type'))
		select.select_by_value('15')
	# Co-apps
	driver.find_element_by_name('txtTot_CoApps').clear()
	driver.find_element_by_name('txtTot_CoApps').send_keys('0')
	# Referral
	driver.find_element_by_name('lstReferral_Type_ID').send_keys('un')
	# Race
	if demogs['Race'][0] == 'Data Not Collected':
		driver.find_element_by_name('lstRace_ID').send_keys('Chose not')
	else:	
		driver.find_element_by_name('lstRace_ID').send_keys(demogs['Race'][0][:2])
	# Is Hispanic
	if demogs['Ethnicity'] == 99:
		driver.find_element_by_name('lstEth_ID').send_keys('chos')
	elif demogs['Ethnicity'] == 1:
		driver.find_element_by_name('lstEth_ID').send_keys('not')
	elif demogs['Ethnicity'] == 2:
		driver.find_element_by_name('lstEth_ID').send_keys('his')
	# Number in HH
	driver.find_element_by_name('txtHH_Num_People').clear()
	driver.find_element_by_name('txtHH_Num_People').send_keys(str(demogs['Members']))

	# Rural
	if demogs['ZipCode'] in ['59715','59718','59771','59772']:
		driver.find_element_by_name('lstRural_Status').send_keys('Does')
	else:
		driver.find_element_by_name('lstRural_Status').send_keys('Lives')

	# Gender
	if demogs['Gender'] == 2:
		driver.find_element_by_xpath('//input[@value="F"]').click()
	elif demogs['Gender'] == 1:
		driver.find_element_by_xpath('//input[@value="M"]').click()

	# Veteran
	if demogs['VeteranStatus'] == 1:
			driver.find_element_by_name('lstVeteran').send_keys('Y')
	elif demogs['VeteranStatus'] == 2:
		driver.find_element_by_name('lstVeteran').send_keys('N')
	else:
		driver.find_element_by_name('lstVeteran').send_keys('Not A')
		

	# English
	if demogs['PrimaryLanguage'] == 1:
		driver.find_element_by_name('lstEnglish_Proficiency').send_keys('Is Eng')
	else:
		driver.find_element_by_name('lstEnglish_Proficiency').send_keys('Is not')

	# Date of Birth
	driver.find_element_by_name('txtBirth_Date').clear()
	driver.find_element_by_name('txtBirth_Date').send_keys(demogs['BirthDate'])

	# Education
	if demogs['Highest Grade Completed'] == 13:
		driver.find_element_by_name('lstEducation_Type_ID').send_keys('voc')
	elif demogs['Highest Grade Completed'] == 10:
		driver.find_element_by_name('lstEducation_Type_ID').send_keys('some')
	elif demogs['Highest Grade Completed'] == 8:
		driver.find_element_by_name('lstEducation_Type_ID').send_keys('high')
	elif demogs['Highest Grade Completed'] == 99:
		driver.find_element_by_name('lstEducation_Type_ID').send_keys('unkno')
	elif demogs['Highest Grade Completed'] == 12:
		driver.find_element_by_name('lstEducation_Type_ID').send_keys('coll')
	elif demogs['Highest Grade Completed'] == 4:
		driver.find_element_by_name('lstEducation_Type_ID').send_keys('Junior H')
	elif demogs['Highest Grade Completed'] == 1:
		driver.find_element_by_name('lstEducation_Type_ID').send_keys('Prim')

	# Marital Status
	if demogs['Marital Status'] == 1 or demogs['Marital Status'] == 7:
		driver.find_element_by_name('lstMarital_Status_ID').send_keys('Sin')
	elif demogs['Marital Status'] == 2:
		driver.find_element_by_name('lstMarital_Status_ID').send_keys('Div')
	elif demogs['Marital Status'] == 5:
		driver.find_element_by_name('lstMarital_Status_ID').send_keys('Comm')
	elif demogs['Marital Status'] == 9:
		driver.find_element_by_name('lstMarital_Status_ID').send_keys('Unk')
	elif demogs['Marital Status'] == 101:
		driver.find_element_by_name('lstMarital_Status_ID').send_keys('Mar')
	elif demogs['Marital Status'] == 102:
		driver.find_element_by_name('lstMarital_Status_ID').send_keys('Liv')
	elif demogs['Marital Status'] == 103:
		driver.find_element_by_name('lstMarital_Status_ID').send_keys('Sep')
	elif demogs['Marital Status'] == 105:
		driver.find_element_by_name('lstMarital_Status_ID').send_keys('Chose')
	else:
		driver.find_element_by_name('lstMarital_Status_ID').send_keys('Unk')

	# Active Military
	if demogs['Active Military'] == 1:
		driver.find_element_by_name('lstActive_Military_Type_ID').send_keys('Y')
	elif demogs['Active Military'] == 2:
		driver.find_element_by_name('lstActive_Military_Type_ID').send_keys('N')
	else:
		driver.find_element_by_name('lstActive_Military_Type_ID').send_keys('Not')
	
	# 1st Homebuyer
	driver.find_element_by_name('lstFirst_Time_Home_Buyer').send_keys('n')
	
	# Annual Income
	driver.find_element_by_name('txtHH_Annual_Income').clear()
	driver.find_element_by_name('txtHH_Annual_Income').send_keys(str(12*demogs['TotalIncome']))

	# County
	driver.find_element_by_name('lstCounty').send_keys(demogs['County'])

	# Current Residence
	if demogs['Prior Residence'] in [1, 4]:
		driver.find_element_by_name('lstCurrent_Residence_Type_ID').send_keys('ot')
	else:
		driver.find_element_by_name('lstCurrent_Residence_Type_ID').send_keys('re')

	confirm = input('Confirm intake information (y/n)?: ')

	if confirm == 'y':
		print('Confirming...')
		driver.find_element_by_name('cmdValidate').send_keys(Keys.RETURN)
		while True:
				try:
					WebDriverWait(driver, 3).until(EC.alert_is_present())
					alert = driver.switch_to.alert
					alert.accept()
					driver.switch_to.default_content()
					driver.implicitly_wait(2)
					driver.find_element_by_id('t0').click()
					pass
				except TimeoutException:
					break
		return True
	elif confirm == 'n':
		print('Make needed changes and confirm (y), or exit without saving (n)')
		re_confirm = input('Confirm (y/n)?: ')
		if re_confirm == 'y':
			print('Confirming...')
			driver.find_element_by_name('cmdValidate').send_keys(Keys.RETURN)
			while True:
				try:
					WebDriverWait(driver, 3).until(EC.alert_is_present())
					alert = driver.switch_to.alert
					alert.accept()
					driver.switch_to.default_content()
					driver.implicitly_wait(2)
					driver.find_element_by_id('t0').click()
					pass
				except TimeoutException:
					break
			return True
		elif re_confirm == 'n':
			print('Returning to client page...')
			driver.switch_to.default_content()
			driver.implicitly_wait(2)
			driver.find_element_by_id('t0').click()
			return False


def exit_enrollment(appt):
	pass


add_appts()