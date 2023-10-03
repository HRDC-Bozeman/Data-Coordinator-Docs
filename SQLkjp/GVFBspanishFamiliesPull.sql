--select * from client
--where PrimaryLanguage = 2 or PrimaryLanguage = 30

select s.ProvidedToEntityID, c.FirstName,c.LastName,c.PrimaryLanguage,s.ServiceID,s.ServiceTypeID, s.ServiceTotal, s.BeginDate from Service s
inner join client c
on c.EntityID=s.ProvidedToEntityID
where (c.PrimaryLanguage = 2 or c.PrimaryLanguage = 30) and (s.BeginDate Between '2022-07-01' and '2023-06-30') and s.AccountID=(140)

select * from service