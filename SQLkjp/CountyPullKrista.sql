select c.EntityID,s.ProvidedToEntityID,c.FirstName,c.LastName, c.gender,c.Race,c.Ethnicity, s.BeginDate, ca.City,ca.county, s.ServiceTotal from Service s
inner join client c
on c.EntityID=s.ProvidedToEntityID
inner join clientaddress ca
on ca.clientID=c.entityID


where(s.BeginDate Between '2023-04-01' and '2023-06-30') 
order by ProvidedToEntityID

select * from ServiceType

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
--homeownership center 157
--housing nav 159/168
--family transitional housing 201
--CLT 197
--DPA 152

--select * from Account
--order by AccountName