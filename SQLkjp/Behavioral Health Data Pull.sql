--select * from assessment
--THis pulls from the chronic homelessness assessment

select ass.ClientID, hud.AssessmentID, MentalIllness, SubstanceAbuse from AssessHUDProgram hud
inner join Assessment Ass
on hud.AssessmentID=ass.AssessmentID



where  hud.ChronicIllness in (5,4,3) or hud.MentalIllness=1 and (ass.CreatedDate Between '2023-01-01' and '2023-09-30') 
-- hud.MentalIllness=1 or hud.SubstanceAbuse in (5,4,3)

-- 1 for mental illness means they do have a mental illness
--3 for substance abuse is alcohlol use disorder
----4 is is drug use disorder
--5 is both alcohol and drug use disorder

--Blueprint HUD 16-24 pull
select ass.ClientID, hud.AssessmentID, X_MentalHealthStatus from AssessHUDProgram hud
inner join Assessment Ass
on hud.AssessmentID=ass.AssessmentID


where  hud.X_MentalHealthStatus in (5,4) and (ass.CreatedDate Between '2022-01-01' and '2022-10-20')

--5 is poor 4 is fair
--Select MentalIllness,SubstanceAbuse from AssessHUDProgram


--THIS DOESNT WORK
--select ass.ClientID, hud.AssessmentID, MentalIllness, SubstanceAbuse from Service s


--inner join Assessment Ass
--on s.ProvidedToEntityID=ass.ClientID

--inner join AssessHUDProgram hud
--on hud.AssessmentID=ass.AssessmentID

--where  hud.ChronicIllness in (5,4,3) and (ass.CreatedDate Between '2022-01-01' and '2022-12-30') and s.AccountID=136