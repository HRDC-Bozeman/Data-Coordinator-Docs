-- this pulls in the date range for people who recieved services in that range for whatever accountid you provide.
--then gives you the last date of assessment and service

--I pull this report by account then in excel I first sort on assessment date newest to oldes then on client id, 
--I then remove duplicates. 
--From there I put in a =datedif() in excel to calculate how many months since last assessment
--I highlight the ones that are <=6


select a.AssessmentID,a.ClientID,a.CreatedDate as CreatedDateAssess,c.FirstName,c.LastName,s.CreatedDate as CreatedDateService from Service s
inner join client c
on s.ProvidedToEntityID=c.EntityID
--inner join Entity e
--on e.EntityID=c.EntityID

inner join Assessment a 
on s.ProvidedToEntityID=a.ClientID
where (s.AccountID in(179)) and (s.BeginDate Between '2023-01-01' and '2023-09-30')
order by a.ClientID

--200 Blueprint
--136 warming center
--181/160 wcl
--erap 178
--housing choice vo 163
--housing 1st 137
--hfv 193
--housing stability services 196
--Headwaters FB 141
--Big Sky FB 142
--GVFB 140
--econ dev 180 and 154
--LIEAP 143
--LIHWAP 187
--RPM 139, 194
--street Outreach 179
--headstart 188 and 189





--select * from Service
--Where AccountID=136 and (s.BeginDate Between '2022-01-01' and '2022-10-11')



--select * from Assessment
--select * from Account
--order by AccountName

----select a.AssessmentID,a.ClientID,a.CreatedDate,c.FirstName,c.LastName from Assessment a
----inner join client c
----on a.ClientID=c.EntityID
------inner join Entity e
------on e.EntityID=c.EntityID

----inner join service s
----on s.ProvidedToEntityID=a.ClientID
----where s.AccountID=136 and (s.BeginDate Between '2022-01-01' and '2022-10-11')
----order by a.ClientID
