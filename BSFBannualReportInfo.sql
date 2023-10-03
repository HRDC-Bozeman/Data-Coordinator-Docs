select a.AssessmentID,a.ClientID,a.CreatedDate as "Assessment Created Date", hud.HousingStatus,c.FirstName,c.LastName,s.CreatedDate as"Service Dates" from Service s
inner join client c
on s.ProvidedToEntityID=c.EntityID
--inner join Entity e
--on e.EntityID=c.EntityID

inner join Assessment a 
on s.ProvidedToEntityID=a.ClientID

inner join AssessHUDProgram hud
on hud.AssessmentID=a.AssessmentID


where (s.BeginDate Between '2022-07-01' and '2023-06-30') and s.AccountID=142
order by a.ClientID


Select * from AssessHUDProgram
select * from Assessment
