/*
BrainStation Capstone Project

Author: Paria Elyasi

2022.08.15
*/

/*
Overview: I am starting with over 8,000,000 rows of data from each table. There are a lot of missing values in this data. 
I will be doing some queries and data cleaning in order to find how many rows of data (with only variables that I am interested in) are actually available.
In the next steps I will be filtering and looking at variables I am interested in for my capstone project. 
I will Join tables and make a final table to export and use in jupyter notebook.
*/

-- Get an overall view of our case table
SELECT *
FROM a_tblcase;

/* 
CASE_TYPE is something we are interested in for our project as we want to look at Asylum cases. 
Looking at the look up csv file in the documents for our data, we are only interested in AOC (Asylum Only Cases), CFR (Credible Fear Review), RFR (Reasonable Fear Case), DEP (Deportation), and RMV (Removal).
We will need to do some digging to see what case_types we want to include in our final cleaned data. First let's look at other columns to see what is available to us. 
*/

 -- Count number of cases in AOC, CFR, RFR, DEP, and RMV
 SELECT COUNT(*)
 FROM a_tblcase
 WHERE CASE_TYPE = 'AOC' OR CASE_TYPE = 'CFR' OR CASE_TYPE = 'RFR' OR CASE_TYPE = 'DEP' OR CASE_TYPE = 'RMV';
 -- There are 6,292,105 total number of cases/rows

 -- Count number of cases for each case_type
SELECT 
	COUNT(*) AS total_cases,
    CASE_TYPE
FROM a_tblcase
WHERE CASE_TYPE = 'AOC' OR CASE_TYPE = 'CFR' OR CASE_TYPE = 'RFR' OR CASE_TYPE = 'DEP' OR CASE_TYPE = 'RMV'
GROUP BY CASE_TYPE;
-- There are 1,106,833 cases in DEP case type , 5,099,787 cases in RMV, 18,742 cases in RFR, 16,364 casess in AOC, and 50,379 cases in CFR

-- Count number of cases in AOC, CFR, RFR, DEP
SELECT COUNT(*) AS total_cases
FROM a_tblcase
WHERE CASE_TYPE = 'AOC' OR CASE_TYPE = 'CFR' OR CASE_TYPE = 'RFR' OR CASE_TYPE = 'DEP';
-- There are 1,192,318 of cases/rows

-- Let's count gender for all cases we are interested in including deportation
-- Note we want all gender columns that don't have an empty value therefore will be using != ''
SELECT COUNT(GENDER)
FROM a_tblcase
WHERE (CASE_TYPE = 'AOC' OR CASE_TYPE = 'CFR' OR CASE_TYPE = 'RFR' OR CASE_TYPE = 'DEP' OR CASE_TYPE = 'RMV') AND (GENDER != '');
-- There are 1,498,078 values in the gender column. 

-- Let's count gender for all cases we are interested in excluding deportation
SELECT COUNT(GENDER)
FROM a_tblcase
WHERE (CASE_TYPE = 'AOC' OR CASE_TYPE = 'CFR' OR CASE_TYPE = 'RFR' OR CASE_TYPE = 'DEP') AND (GENDER != '');
-- If we don't include the removal case type, there are only 29,490 values in the gender column. This means that there are alot of missing values (~98%) in our gender column. 
-- Need to decide how to handle the missing values in gender column. Should we not use GENDER column at all or should we use it and include RMV as casetype to have more rows of data to work with? 

-- Let's look at gender count group by case_type
SELECT COUNT(GENDER), CASE_TYPE
FROM a_tblcase
WHERE (CASE_TYPE = 'AOC' OR CASE_TYPE = 'CFR' OR CASE_TYPE = 'RFR' OR CASE_TYPE = 'DEP' OR CASE_TYPE = 'RMV') AND (GENDER != '')
GROUP BY CASE_TYPE;
-- RMV casetype has the highest number of rows (1,468,588) with gender value present

-- Look at birthdate column to see how many values/rows are availabe for the casetypes we are interested in
SELECT COUNT(C_BIRTHDATE)
FROM a_tblcase
WHERE (CASE_TYPE = 'AOC' OR CASE_TYPE = 'CFR' OR CASE_TYPE = 'RFR' OR CASE_TYPE = 'DEP' OR CASE_TYPE = 'RMV') AND (GENDER != '') AND (C_BIRTHDATE != '');
-- There are 1,260,432 values, this means that around 180,000 rows from our previous query with casetype and gender don't have birthdates

-- now let's look at the bithdate column to see how the values are presented in the data we have
SELECT C_BIRTHDATE
FROM a_tblcase
WHERE (CASE_TYPE = 'AOC' OR CASE_TYPE = 'CFR' OR CASE_TYPE = 'RFR' OR CASE_TYPE = 'DEP' OR CASE_TYPE = 'RMV') AND (GENDER != '') AND (C_BIRTHDATE != '');
-- The birthdates in our data have month and year. We would need to do feature engineering to convert these and get the age of the case applicants

-- Let's look at all the columns in our previous query
SELECT *
FROM a_tblcase
WHERE (CASE_TYPE = 'AOC' OR CASE_TYPE = 'CFR' OR CASE_TYPE = 'RFR' OR CASE_TYPE = 'DEP' OR CASE_TYPE = 'RMV') AND (GENDER != '') AND (C_BIRTHDATE != '');

/*
In the above section, we looked at a_tblcase and it's columns. 
We are interested in the below columns from this table:
1. IDNCASE
2. ALIEN_CITY
3. ALIEN_STATE
4. NAT
5. LANG
6. CUSTODY
7. CASE_TYPE
8. GENDER
9. C_BIRTHDATE
10. ATTY_NBR
*/

-- Now we will look at the b_tblproceeding table
SELECT *
FROM b_tblproceeding;

-- Look at DEC_TYPE and DEC_CODE where values are not missing
SELECT DEC_TYPE, DEC_CODE
FROM b_tblproceeding
WHERE (DEC_TYPE != ' ' AND DEC_TYPE !='') AND (DEC_CODE != ' ' AND DEC_CODE !='');
-- Note some values had spaces in there hence having to use two different types of where clause

-- Now let's count the above query to see how many values we have available
SELECT COUNT(*)
FROM b_tblproceeding
WHERE (DEC_TYPE != ' ' AND DEC_TYPE !='') AND (DEC_CODE != ' ' AND DEC_CODE !='');
-- There are 5,513,730 total counts for both

-- Now let's group by to see how many different decision code there are
SELECT COUNT(*), DEC_CODE
FROM b_tblproceeding
WHERE (DEC_TYPE != ' ' AND DEC_TYPE !='') AND (DEC_CODE != ' ' AND DEC_CODE !='')
GROUP BY DEC_CODE;
-- There should be a total of 12 decidion codes according to the lookup table provided with the tables however we can see some rows have invalid entry in there by mistake.

/*
There are 12 diffrerent decision codes:
A : Legally Admitted --> Accepted
C : Conditional Grand --> Accepted
D : Deported --> Rejected
E : Excluded
G : Granted --> Accepted
O : Other
R : Relief/Rescinded --> This means relief from removal therefore considered --> Accepted
S : Alien Maintains Legal Status
T : Case Terminated By Immigration Judge
V : Voluntary Departure
W : Withdrawn
X : Removed --> Rejected


We will only be looking at the Accepted and Rejected ones which are as follows:
Accepted: A, C, G, R
Rejected: D, X 
*/

-- let's look at only the ones we are interested in and get a total count
SELECT COUNT(*)
FROM b_tblproceeding
WHERE 
	(DEC_TYPE != ' ' AND DEC_TYPE !='') 
    AND (DEC_CODE != ' ' AND DEC_CODE !='') 
    AND (DEC_CODE = 'A' OR DEC_CODE = 'C' OR DEC_CODE = 'G' OR DEC_CODE = 'R' OR DEC_CODE = 'D' OR DEC_CODE = 'X');
-- There are 4,113,565 rows total

-- Get count for each decision code
SELECT 
	COUNT(*) as total_count, 
    DEC_CODE
FROM b_tblproceeding
WHERE 
	(DEC_TYPE != ' ' AND DEC_TYPE !='') 
    AND (DEC_CODE != ' ' AND DEC_CODE !='') 
    AND (DEC_CODE = 'A' OR DEC_CODE = 'C' OR DEC_CODE = 'G' OR DEC_CODE = 'R' OR DEC_CODE = 'D' OR DEC_CODE = 'X')
GROUP BY DEC_CODE
ORDER BY total_count DESC;

-- Get count for Accepted only
SELECT 
	COUNT(*) as total_count
FROM b_tblproceeding
WHERE 
	(DEC_TYPE != ' ' AND DEC_TYPE !='') 
    AND (DEC_CODE != ' ' AND DEC_CODE !='') 
    AND (DEC_CODE = 'A' OR DEC_CODE = 'C' OR DEC_CODE = 'G' OR DEC_CODE = 'R');
-- there are 730,507 total cases that have been approved based on the filters in our query (no missing values in DEC_TYPE and DEC_CODE)

-- Get count for Rejected only
SELECT 
	COUNT(*) as total_count
FROM b_tblproceeding
WHERE 
	(DEC_TYPE != ' ' AND DEC_TYPE !='') 
    AND (DEC_CODE != ' ' AND DEC_CODE !='') 
    AND (DEC_CODE = 'D' OR DEC_CODE = 'X');
-- There are 3,383,058 total cases that have been rejected based on the filters in our query (no missing values in DEC_TYPE and DEC_CODE)

-- Look at case type and decision code, note that we do not want missing value for case type
SELECT 
	COUNT(*) as total_count,
    DEC_CODE,
    CASE_TYPE
FROM b_tblproceeding
WHERE 
	(DEC_TYPE != ' ' AND DEC_TYPE !='') 
    AND (DEC_CODE != ' ' AND DEC_CODE !='') 
    AND (DEC_CODE = 'A' OR DEC_CODE = 'C' OR DEC_CODE = 'G' OR DEC_CODE = 'R' OR DEC_CODE = 'D' OR DEC_CODE = 'X')
    AND (CASE_TYPE = 'AOC' OR CASE_TYPE = 'CFR' OR CASE_TYPE = 'RFR' OR CASE_TYPE = 'DEP' OR CASE_TYPE = 'RMV')
GROUP BY CASE_TYPE
ORDER BY total_count DESC;

-- get a total count for the query above
SELECT 
	COUNT(*) as total_count
FROM b_tblproceeding
WHERE 
	(DEC_TYPE != ' ' AND DEC_TYPE !='') 
    AND (DEC_CODE != ' ' AND DEC_CODE !='') 
    AND (DEC_CODE = 'A' OR DEC_CODE = 'C' OR DEC_CODE = 'G' OR DEC_CODE = 'R' OR DEC_CODE = 'D' OR DEC_CODE = 'X')
    AND (CASE_TYPE = 'AOC' OR CASE_TYPE = 'CFR' OR CASE_TYPE = 'RFR' OR CASE_TYPE = 'DEP' OR CASE_TYPE = 'RMV');
-- There are 4,083,954 total rows with case type and decision code in this table


-- get judges count info from table
SELECT COUNT(*)
FROM b_tblproceeding
WHERE (IJ_CODE != '' AND IJ_CODE != ' ');
-- There are 8,636,894 rows that have immigration judge's info

-- let's take a look at these rows
SELECT 
	IJ_CODE,
    CASE_TYPE,
    DEC_CODE
FROM b_tblproceeding
WHERE 
	(IJ_CODE != '' AND IJ_CODE != ' ')
	AND (DEC_TYPE != ' ' AND DEC_TYPE !='') 
    AND (DEC_CODE != ' ' AND DEC_CODE !='') 
    AND (DEC_CODE = 'A' OR DEC_CODE = 'C' OR DEC_CODE = 'G' OR DEC_CODE = 'R' OR DEC_CODE = 'D' OR DEC_CODE = 'X')
    AND (CASE_TYPE = 'AOC' OR CASE_TYPE = 'CFR' OR CASE_TYPE = 'RFR' OR CASE_TYPE = 'DEP' OR CASE_TYPE = 'RMV');
    
-- let's do a count for the above query
SELECT COUNT(*)
FROM b_tblproceeding
WHERE 
	(IJ_CODE != '' AND IJ_CODE != ' ')
	AND (DEC_TYPE != ' ' AND DEC_TYPE !='') 
    AND (DEC_CODE != ' ' AND DEC_CODE !='') 
    AND (DEC_CODE = 'A' OR DEC_CODE = 'C' OR DEC_CODE = 'G' OR DEC_CODE = 'R' OR DEC_CODE = 'D' OR DEC_CODE = 'X')
    AND (CASE_TYPE = 'AOC' OR CASE_TYPE = 'CFR' OR CASE_TYPE = 'RFR' OR CASE_TYPE = 'DEP' OR CASE_TYPE = 'RMV');
-- There are 4,074,521 rows of data that have case type, judge code, and decision code

/*
In the above section, we looked at b_tblProceeding and it's columns. 
We are interested in the below columns from this table:
1. IDNCASE Primary Key
2. OSC_Date --> Date Department of Homeland Security sent the notice to appear
3. HEARING_DATE
4. HEARING_LOC_CODE
5. IJ_CODE
6. DEC_CODE
7. ABSENTIA
8. CASE_TYPE
9. CRIM_IND
*/

-- We can select the columns that we want and join with a_tblcase table

SELECT 
	a_tblcase.IDNCASE,
    a_tblcase.ALIEN_CITY,
    a_tblcase.ALIEN_STATE,
    a_tblcase.NAT,
    a_tblcase.LANG,
    a_tblcase.CUSTODY,
    a_tblcase.ATTY_NBR,
    a_tblcase.CASE_TYPE,
    a_tblcase.DATE_OF_ENTRY,
    a_tblcase.GENDER,
    a_tblcase.C_BIRTHDATE,
    b_tblproceeding.IDNCASE,
    b_tblproceeding.OSC_DATE,
    b_tblproceeding.HEARING_DATE,
    b_tblproceeding.HEARING_LOC_CODE,
    b_tblproceeding.IJ_CODE,
    b_tblproceeding.DEC_CODE,
    b_tblproceeding.ABSENTIA,
    b_tblproceeding.CASE_TYPE,
    b_tblproceeding.CRIM_IND
FROM a_tblcase
JOIN b_tblproceeding
ON a_tblcase.IDNCASE = b_tblproceeding.IDNCASE
WHERE (a_tblcase.CASE_TYPE = 'AOC' OR a_tblcase.CASE_TYPE = 'CFR' OR a_tblcase.CASE_TYPE = 'RFR' OR a_tblcase.CASE_TYPE = 'DEP' OR a_tblcase.CASE_TYPE = 'RMV') 
AND (a_tblcase.GENDER != '') 
AND (a_tblcase.C_BIRTHDATE != '')
AND (a_tblcase.ATTY_NBR != '')
AND (a_tblcase.ATTY_NBR != ' ');
-- There are 1,690,647 rows before adding the ATTY_NBR
-- There are 1,033,872 rows after adding the ATTY_NBR


-- Query the above table and join with nationality and only show rows with the DEC_CODE specified
SELECT 
    Asylum_Table.IDNCASE,
    Asylum_Table.NAT,
    tbllookupnationality.NAT_NAME,
    Asylum_Table.GENDER,
    Asylum_Table.C_BIRTHDATE,
    Asylum_Table.LANG,
    Asylum_Table.ALIEN_CITY,
    Asylum_Table.ALIEN_STATE,
    Asylum_Table.CASE_TYPE,
    Asylum_Table.DATE_OF_ENTRY,
    Asylum_Table.OSC_DATE,
    Asylum_Table.HEARING_DATE,
    Asylum_Table.HEARING_LOC_CODE,
    Asylum_Table.CUSTODY,
    Asylum_Table.CRIM_IND,
	Asylum_Table.ATTY_NBR,
    Asylum_Table.ABSENTIA,
    Asylum_Table.IJ_CODE,
    Asylum_Table.DEC_CODE
FROM
(SELECT 
	a_tblcase.IDNCASE,
    a_tblcase.NAT,
    a_tblcase.GENDER,
    a_tblcase.C_BIRTHDATE,
    a_tblcase.LANG,
    a_tblcase.ALIEN_CITY,
    a_tblcase.ALIEN_STATE,
    a_tblcase.CASE_TYPE,
    a_tblcase.DATE_OF_ENTRY,
    b_tblproceeding.OSC_DATE,
    b_tblproceeding.HEARING_DATE,
    b_tblproceeding.HEARING_LOC_CODE,
    a_tblcase.CUSTODY,
    b_tblproceeding.CRIM_IND,
	a_tblcase.ATTY_NBR,
    b_tblproceeding.ABSENTIA,
    b_tblproceeding.IJ_CODE,
    b_tblproceeding.DEC_CODE
FROM a_tblcase
JOIN b_tblproceeding
ON a_tblcase.IDNCASE = b_tblproceeding.IDNCASE
WHERE (a_tblcase.CASE_TYPE = 'AOC' OR a_tblcase.CASE_TYPE = 'CFR' 
OR a_tblcase.CASE_TYPE = 'RFR' OR a_tblcase.CASE_TYPE = 'DEP' 
OR a_tblcase.CASE_TYPE = 'RMV') 
AND (a_tblcase.GENDER != '') 
AND (a_tblcase.C_BIRTHDATE != '')
) AS Asylum_Table
JOIN tbllookupnationality
ON Asylum_Table.NAT = tbllookupnationality.NAT_CODE
WHERE (Asylum_Table.DEC_CODE = 'A' OR Asylum_Table.DEC_CODE = 'C' 
OR Asylum_Table.DEC_CODE = 'G' OR Asylum_Table.DEC_CODE = 'R' 
OR Asylum_Table.DEC_CODE = 'D' OR Asylum_Table.DEC_CODE = 'X');

-- Note that ATTY_NBR will be removed from WHERE clause as we can consider NaN rows as uknown or no representation (0). 
-- This will be decided later in our data cleaning/preprocessing in jupyter notebook.


-- Next step is to make a table from the above query
-- Safety check 

DROP TABLE IF EXISTS asylum_cases;

-- Create table
CREATE TABLE asylum_cases (
SELECT 
    Asylum_Table.IDNCASE,
    Asylum_Table.NAT,
    tbllookupnationality.NAT_NAME,
    Asylum_Table.GENDER,
    Asylum_Table.C_BIRTHDATE,
    Asylum_Table.LANG,
    Asylum_Table.ALIEN_CITY,
    Asylum_Table.ALIEN_STATE,
    Asylum_Table.CASE_TYPE,
    Asylum_Table.DATE_OF_ENTRY,
    Asylum_Table.OSC_DATE,
    Asylum_Table.HEARING_DATE,
    Asylum_Table.HEARING_LOC_CODE,
    Asylum_Table.CUSTODY,
    Asylum_Table.CRIM_IND,
	Asylum_Table.ATTY_NBR,
    Asylum_Table.ABSENTIA,
    Asylum_Table.IJ_CODE,
    Asylum_Table.DEC_CODE
FROM
(SELECT 
	a_tblcase.IDNCASE,
    a_tblcase.NAT,
    a_tblcase.GENDER,
    a_tblcase.C_BIRTHDATE,
    a_tblcase.LANG,
    a_tblcase.ALIEN_CITY,
    a_tblcase.ALIEN_STATE,
    a_tblcase.CASE_TYPE,
    a_tblcase.DATE_OF_ENTRY,
    b_tblproceeding.OSC_DATE,
    b_tblproceeding.HEARING_DATE,
    b_tblproceeding.HEARING_LOC_CODE,
    a_tblcase.CUSTODY,
    b_tblproceeding.CRIM_IND,
	a_tblcase.ATTY_NBR,
    b_tblproceeding.ABSENTIA,
    b_tblproceeding.IJ_CODE,
    b_tblproceeding.DEC_CODE
FROM a_tblcase
JOIN b_tblproceeding
ON a_tblcase.IDNCASE = b_tblproceeding.IDNCASE
WHERE (a_tblcase.CASE_TYPE = 'AOC' OR a_tblcase.CASE_TYPE = 'CFR' 
OR a_tblcase.CASE_TYPE = 'RFR' OR a_tblcase.CASE_TYPE = 'DEP' 
OR a_tblcase.CASE_TYPE = 'RMV') 
AND (a_tblcase.GENDER != '') 
AND (a_tblcase.C_BIRTHDATE != '')
) AS Asylum_Table
JOIN tbllookupnationality
ON Asylum_Table.NAT = tbllookupnationality.NAT_CODE
WHERE (Asylum_Table.DEC_CODE = 'A' OR Asylum_Table.DEC_CODE = 'C' 
OR Asylum_Table.DEC_CODE = 'G' OR Asylum_Table.DEC_CODE = 'R' 
OR Asylum_Table.DEC_CODE = 'D' OR Asylum_Table.DEC_CODE = 'X')
);

-- checking to make sure table has been created
SELECT *
FROM asylum_cases;

-- Join in hearing location, decision type and decision code with our asylum_cases table.
SELECT
	asylum_cases.*,
    tbllookuphloc.HEARING_CITY,
    tbllookuphloc.HEARING_STATE,
    tbllookupcasetype.strDescription AS CASE_DESCRIPTION,
    tbldeccode.strDescription AS DEC_DESCRIPTION,
    tbllookupcustodystatus.strDescription AS CUSTODY_DESCRIPTION,
    tbllanguage.strDescription AS LANGUAGES
FROM asylum_cases
JOIN tbllookuphloc
ON asylum_cases.HEARING_LOC_CODE = tbllookuphloc.HEARING_LOC_CODE
JOIN tbllookupcasetype
ON asylum_cases.CASE_TYPE = tbllookupcasetype.strCode
JOIN tbldeccode
ON asylum_cases.DEC_CODE = tbldeccode.strCode
JOIN tbllookupcustodystatus
ON asylum_cases.CUSTODY = tbllookupcustodystatus.strCode
JOIN tbllanguage
ON asylum_cases.LANG = tbllanguage.strCode;

-- now that we have finalized our columns, we can make a final table to convert to csv and work on additional data cleaning and EDA in jupyter notebook.

-- Safety check 
DROP TABLE IF EXISTS immigration_asylum_dataset;


-- Create table
CREATE TABLE immigration_asylum_dataset (
SELECT
	asylum_cases.IDNCASE,
    asylum_cases.NAT AS NAT_CODE,
    asylum_cases.NAT_NAME AS NATIONALITY,
    asylum_cases.GENDER,
    asylum_cases.C_BIRTHDATE AS BIRTHDATE,
    asylum_cases.LANG AS LANG_CODE,
    tbllanguage.strDescription AS LANGUAGES,
    asylum_cases.ALIEN_CITY,
    asylum_cases.ALIEN_STATE,
    asylum_cases.CASE_TYPE,
    tbllookupcasetype.strDescription AS CASE_DESCRIPTION,
    asylum_cases.DATE_OF_ENTRY,
    asylum_cases.OSC_DATE AS NOTICE_DATE,
    asylum_cases.HEARING_DATE,
    asylum_cases.HEARING_LOC_CODE,
    tbllookuphloc.HEARING_CITY,
    tbllookuphloc.HEARING_STATE,
    asylum_cases.CUSTODY AS CUSTODY_CODE,
    tbllookupcustodystatus.strDescription AS CUSTODY,
    asylum_cases.CRIM_IND AS CRIMINAL_RECORD,
    asylum_cases.ATTY_NBR,
    asylum_cases.ABSENTIA,
    asylum_cases.IJ_CODE,
    asylum_cases.DEC_CODE,
    tbldeccode.strDescription AS DECISION
FROM asylum_cases
JOIN tbllookuphloc
ON asylum_cases.HEARING_LOC_CODE = tbllookuphloc.HEARING_LOC_CODE
JOIN tbllookupcasetype
ON asylum_cases.CASE_TYPE = tbllookupcasetype.strCode
JOIN tbldeccode
ON asylum_cases.DEC_CODE = tbldeccode.strCode
JOIN tbllookupcustodystatus
ON asylum_cases.CUSTODY = tbllookupcustodystatus.strCode
JOIN tbllanguage
ON asylum_cases.LANG = tbllanguage.strCode);

#Check to make sure table has been made
SELECT *
FROM immigration_asylum_dataset;

