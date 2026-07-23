--pulls minimal client info for folks who have had a case management service
--set your time range as needed

select s.ProvidedToEntityID,s.FamilyID,c.FirstName,c.LastName,c.BirthDate,c.Gender,c.EnglishProficiency,
s.CreatedDate as CreatedDateService, s.AccountID, a.AccountName,s.ServiceID,st.Description,s.ServiceTypeID,s.ServiceTotal from Service s
inner join client c
on s.ProvidedToEntityID=c.EntityID
inner join ServiceType st
on st.ServiceTypeID=s.ServiceTypeID
inner join Account a
on a.AccountID =s.AccountID
--inner join Entity e
--on e.EntityID=c.EntityID


where (s.BeginDate Between '2025-07-01' and '2026-06-30') 


--the Case manage ment servicetypeIDs
and s.ServiceTypeID in (539,100)
--and c.EntityID in (


--how you find the right se4rvice ID codes
--Select * from ServiceType
--order by Description