----select * from provider

----select * from workhistory
----select * from AssessHUDProgram


--select a.AssessmentID,a.ClientID,a.CreatedDate as CreatedDateAssess,c.FirstName,c.LastName, pro.ProviderName as 'EmployerName',s.CreatedDate as CreatedDateService from Service s

--inner join client c
--on s.ProvidedToEntityID=c.EntityID

--inner join Assessment a 
--on s.ProvidedToEntityID=a.ClientID

--inner join AssessHUDProgram hud
--on hud.AssessmentID=a.AssessmentID

--inner join WorkHistory wh
--on wh.ClientID=a.ClientID

--inner join Provider pro
--on pro.EntityID=wh.ProviderID

--where (s.AccountID=(142)) and (s.BeginDate Between '2015-07-01' and '2016-06-30')
--order by a.ClientID



select c.entityID, c.FirstName,c.LastName, c.VeteranStatus,s.CreatedDate as CreatedDateService from Service s

inner join client c
on s.ProvidedToEntityID=c.EntityID


where (s.AccountID=(142)) and (s.BeginDate Between '2022-07-01' and '2023-06-30')
order by c.EntityID

