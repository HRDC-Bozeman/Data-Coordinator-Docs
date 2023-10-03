select a.AssessmentID,a.ClientID,a.CreatedDate, hud.Employed, p.ProviderName, hud.EmploymentType,s.CreatedDate from Service s
--inner join client c
--on s.ProvidedToEntityID=c.EntityID
--inner join Entity e
--on e.EntityID=c.EntityID

inner join Assessment a 
on s.ProvidedToEntityID=a.ClientID

inner join AssessHUDProgram hud
on hud.AssessmentID=a.AssessmentID

inner join provider p
on p.EntityID=a.AssessmentID

where (s.BeginDate Between '2022-01-01' and '2023-07-26') --and s.AccountID=142
order by a.ClientID


--select * from AssessHUDProgram
select * from Provider
--select * from Provider