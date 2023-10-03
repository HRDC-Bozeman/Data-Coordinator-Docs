select os.domainID,os.scoreID, os.outcomevalue,os.shortdescription,os.longdescription,od.domainname from outcomescore os
inner join outcomedomain od
on os.domainid= od.domainid
where od.domainname ='income' or od.domainname ='employment' or od.domainname = 'childcare' or od.domainname ='housing' or od.domainname = 'food security' or od.domainname ='Health care/services' or od.domainname = 'education' or od.domainname ='nutrition' or od.domainname = 'transportation' or od.domainname = 'financial literacy'
order by DomainName

--select * from outcomedomain
