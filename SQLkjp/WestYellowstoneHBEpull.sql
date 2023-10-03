select c.EntityID,s.ProvidedToEntityID,c.FirstName,c.LastName, c.gender,c.Race,c.Ethnicity, s.BeginDate, ca.City,ca.county,st.Description, s.ServiceTotal from Service s
inner join client c
on c.EntityID=s.ProvidedToEntityID
inner join clientaddress ca
on ca.clientID=c.entityID
inner join ServiceType st
on st.ServiceTypeID=s.ServiceTypeID

where(s.BeginDate Between '2017-01-01' and '2023-09-30') and s.ServiceTypeID in (927,928,929,931,931,938,937,936,932,933,934,935) and ca.City='West Yellowstone'
order by ProvidedToEntityID

--select * from ServiceType
--order by Description