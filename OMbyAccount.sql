select s.ProvidedToEntityID,c.FirstName,c.LastName,s.CreatedDate as CreatedDateService,o.OutcomeID,o.ScoreID,o.CreatedDate as CreatedOutcomeDate,  OD.DomainName 'Domain'
	   , OS.OutcomeValue 'Score' from Service s
inner join client c
	on s.ProvidedToEntityID=c.EntityID
inner join Outcome O
	on o.EntityID=s.ProvidedToEntityID
INNER JOIN OutcomeDomain OD
	ON OD.DomainID = O.DomainID
INNER JOIN OutcomeScore OS
	ON OS.ScoreID = O.ScoreID

where (s.AccountID=141) 
--and (s.BeginDate Between '2023-01-01' and '2023-06-15')
order by s.providedtoEntityID



--select * from Outcome