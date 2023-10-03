select c.EntityID, c.FirstName,c.LastName,s.CreatedDate, ca.Address1,ca.Address2,ca.ZipCode,ca.City,ca.State,ca.AddressID  from Service s
inner join client c
on s.ProvidedToEntityID=c.EntityID
inner join ClientAddress ca
on c.EntityID=ca.ClientID

where (s.AccountID=(192) or s.AccountID=194) and (s.BeginDate Between '2022-01-01' and '2023-09-05')
order by c.EntityID, ca.AddressID


--select * from Account
--order by AccountName





