
-- the number of patients who have been admitted x times  
select distinct n.HADM_ID, count( distinct n.subject_id)
from (select p.subject_id, count(distinct A.HADM_ID) as HADM_ID from admissions A join patients p where p.subject_id=a.subject_id group by p.SUBJECT_ID) n group by n.HADM_ID;

-- views for  patients with 5 or more admissions from diagnoses_icd / prescriptions /procedures_icd tables
CREATE VIEW diagviews as select * from diagnoses_icd where  exists ( select p.subject_id, count( distinct a.HADM_ID) as h from admissions a join patients p on p.subject_id=a.subject_id group by p.subject_id having count(distinct HADM_ID) >4 );

CREATE VIEW diagviewerss as select * from diagnoses_icd where  exists ( select p.subject_id, count( distinct a.HADM_ID) as h from admissions a join patients p on  p.subject_id=a.subject_id group by p.subject_id having count(distinct HADM_ID) >4  );

--	Create a temporary table T for diagnoses_icd with only the first three characters of the diagnosis code. 

create temporary table T as 
select *, left(icd9_code, 3) as new_code
from diagnoses_icd;

-- count the number of unique diagnoses in T
SELECT COUNT(DISTINCT new_code) FROM T AS  numUnique_diagnoses ;

-- 	count the number of unique diagnoses for each patient in T
SELECT T.new_code, COUNT(DISTINCT p.subject_id )  AS   numPatient_diagnoses FROM patients p join T  ON p.SUBJECT_ID=T.SUBJECT_ID GROUP BY T.new_code ;

-- 	Temporary table T1 with the first three digits in every diagnosis in addition to any letters   

create temporary table T1 as
select *, 
case CAST(ICD9_CODE as char)
	when left(ICD9_CODE, 1) like '[A-Za-z]%' then left(icd9_code,  4 )
	else left(icd9_code, 3)
end as newICD9_code
from  diagnoses_icd;


-- 	count the number of unique diagnoses in T1
SELECT COUNT(DISTINCT newICD9_code) FROM T1 AS  numUnique_diagnoses ;

-- 	count the number of unique diagnoses for each patient in T1

SELECT T1.newICD9_code, COUNT(DISTINCT p.subject_id )  AS   numPatient_diagnoses FROM patients p join T1  ON p.SUBJECT_ID=T1.SUBJECT_ID GROUP BY T1.newICD9_code ;


-- Count patients diagnosed for each ICD-9 code* and list the top 10 most common diagnoses
create view t1_views as
select *, 
case CAST(ICD9_CODE as char)
	when left(ICD9_CODE, 1) like '[A-Za-z]%' then left(icd9_code,  4 )
	else left(icd9_code, 3)
end as newICD9_code
from  diagnoses_icd;

CREATE VIEW new_view as select * from t1_view where  exists (SELECT t1_view.newICD9_code, COUNT(DISTINCT p.subject_id )  AS   numPatient_diagnoses FROM patients p join t1_view  ON p.SUBJECT_ID=t1_view.SUBJECT_ID GROUP BY t1_view.newICD9_code );

select n.newICD9_code
from diagnoses_icd d
where  exists  (SELECT T1.newICD9_code, COUNT(DISTINCT p.subject_id )  AS   numPatient_diagnoses FROM patients p join T1  ON p.SUBJECT_ID=T1.SUBJECT_ID GROUP BY T1.newICD9_code ) n

 
select *
from  (SELECT t1.newICD9_code , COUNT(DISTINCT p.subject_id  )  AS   numPatient_diagnoses FROM patients p join T1  ON p.SUBJECT_ID=T1.SUBJECT_ID GROUP BY t1.newICD9_code ) n
order by n.numPatient_diagnoses desc
limit 10;
