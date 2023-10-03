select c.entityid ,c.FirstName,c.LastName,s.CreatedDate as CreatedDateService, s.servicetypeid, s.servicetotal, s.ServiceID from Service s
inner join client c
on s.ProvidedToEntityID=c.EntityID
--inner join Entity e
--on e.EntityID=c.EntityID


where (s.AccountID=196) and (s.BeginDate Between '2023-08-01' and '2023-08-31')
order by c.entityid


--select * from service