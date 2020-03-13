/*
There are three issues that include the words "index" and "Oracle". Find the call_date for each of them
*/

SELECT call_date, call_ref, Detail
  FROM Issue
WHERE Detail Like "%index%" AND Detail Like "%Oracle%"

-- #2
/*
Samantha Hall made three calls on 2017-08-14. Show the date and time for each
*/

SELECT call_date, first_name, last_name
  FROM Issue 
  JOIN Caller
  ON Issue.Caller_id = Caller.Caller_id
  WHERE first_name = 'Samantha' AND last_name = 'Hall' 
        AND call_date LIKE '%2017-08-14%'

-- #3
/*
There are 500 calls in the system (roughly). Write a query that shows the number that have each status.
*/

SELECT status, COUNT(*) AS Volume
  from Issue
GROUP BY status

-- #4
/*
Calls are not normally assigned to a manager but it does happen. How many calls have been assigned to staff who are at Manager Level?
*/

SELECT 
   COUNT(*) AS mlcc
   FROM Issue
   JOIN Staff 
     ON Issue.Assigned_to = Staff.Staff_code 
   WHERE Level_code IN 
                   (SELECT Level_code
                    FROM Level
                    WHERE Manager = 'Y')
                    
-- #5
/*
Show the manager for each shift. Your output should include the shift date and type; also the first and last name of the manager.
*/

SELECT shift_date, Shift_type, First_name, Last_name
  FROM Shift
  JOIN Staff
  ON Staff.Staff_code = Shift.Manager 
ORDER BY 1,2

-- #6
/*
List the Company name and the number of calls for those companies with more than 18 calls.
*/

SELECT Company_name, COUNT(*) AS cc
  FROM Caller 
  JOIN Issue 
  ON Caller.Caller_id = Issue.Caller_id
  JOIN Customer
  ON Customer.company_ref = Caller.company_ref
GROUP BY 1
HAVING cc > 18

-- #7
/*
Find the callers who have never made a call. Show first name and last name
*/

SELECT First_name, Last_name
  FROM Caller
  LEFT JOIN Issue
  ON Caller.Caller_id = Issue.Caller_id 
WHERE Issue.Caller_id IS NULL

-- #8
/*
For each customer show: Company name, contact name, number of calls where the number of calls is fewer than 5
*/

SELECT Company_name, First_name, Last_name, COUNT(Call_ref) AS nc 
  FROM Caller
  LEFT JOIN Issue
  ON Caller.Caller_id = Issue.Caller_id
  JOIN Customer
  ON Caller.Company_ref = Customer.Company_ref 
GROUP BY 1
HAVING nc<5
