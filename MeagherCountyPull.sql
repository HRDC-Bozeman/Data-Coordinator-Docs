select s.ServiceID, s.ProvidedToEntityID,c.FirstName,c.LastName,c.gender,c.Race,c.Ethnicity,c.BirthDate, s.BeginDate,ca.county,st.Description,a.AccountName, s.ServiceTotal from Service s
inner join client c
on c.EntityID=s.ProvidedToEntityID
inner join clientaddress ca
on ca.clientID=c.entityID
inner join ServiceType st
on st.ServiceTypeID=s.ServiceTypeID
inner join Account a 
on a.AccountID=s.AccountID

where(s.BeginDate Between '2022-01-01' and '2022-12-31') and ca.County='Meagher'
order by ProvidedToEntityID


----select AccountID from Service
--select * from Account
--select * from ServiceType
select * from ClientOtherInfo