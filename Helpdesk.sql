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

When you do LEFT JOIN, the missing values of table2 will assign NULL to that field you're joining on
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

-- #9
/*
For each shift show the number of staff assigned. Beware that some roles may be NULL and that the same person might have been assigned to multiple roles (The roles are 'Manager', 'Operator', 'Engineer1', 'Engineer2').

This is what you want your table to look like, so you can group by 1,2, and COUNT the DISTINCT staff_code
Do this with UNION
+------------+------------+------------+
| Shift_date | Shift_type | Staff_code |
+------------+------------+------------+
| 2017-08-12 | Early      |  Manager   |
| 2017-08-12 | Early      |  Operator  |
| 2017-08-12 | Early      |  Engineer1 |
| 2017-08-12 | Early      |  Engineer2 |
*/

SELECT Shift_date, Shift_type, COUNT(DISTINCT Staff_X) AS cw
  FROM(
      SELECT Shift_date,  Shift_type, Manager AS Staff_X
      FROM Shift
      UNION
      SELECT Shift_date,  Shift_type, Operator AS Staff_X
      FROM Shift
      UNION 
      SELECT Shift_date,  Shift_type, Engineer1 AS Staff_X
      FROM Shift
      UNION 
      SELECT Shift_date,  Shift_type, Engineer2 AS Staff_X
      FROM Shift
      ) AS t
GROUP BY 1,2

-- #10
/*
Caller 'Harry' claims that the operator who took his most recent call was abusive and insulting. Find out who took the call (full name) and when.
*/

SELECT Staff.First_name, Staff.Last_name, Call_date
  FROM Caller
  JOIN Issue 
    ON Caller.Caller_id = Issue.Caller_id 
  JOIN Staff
    ON Issue.Taken_by = Staff.Staff_code 
  WHERE Caller.First_name = 'Harry'
  
  ORDER BY Call_date DESC
  LIMIT 1

-- #11
/*
Show the manager and number of calls received for each hour of the day on 2017-08-12
*/

SELECT Manager, 
       DATE_FORMAT(Call_date, '%Y-%m-%d %H') Hr, 
       COUNT(Call_ref) AS cc
  FROM Issue 
  JOIN Shift_type 
    ON HOUR(Call_date) >= Start_time AND HOUR(Call_date) < End_time
  JOIN Shift
    ON Shift.Shift_type = Shift_type.Shift_type
  WHERE Call_date LIKE '%2017-08-12%' AND Shift_date LIKE '%2017-08-12%'
GROUP BY 1,2
ORDER BY 2

-- #12
/*
80/20 rule. It is said that 80% of the calls are generated by 20% of the callers. Is this true? What percentage of calls are generated by the most active 20% of callers.

Steps/thought process: 
- aggregate #of calls by caller_id 
- rank the caller_id from most calls to least, and assign a ranking #
- convert the ranking # to percentages 
- only select the 20% top callers - and match the calls from original table to them 
*/

SELECT COUNT(*)*100/(SELECT COUNT(DISTINCT Call_ref)FROM Issue) AS 't20pc'
  FROM Issue
 WHERE Caller_id in (SELECT Caller_id 
     FROM(
           SELECT *, 
           row*100/(SELECT COUNT(DISTINCT Caller_id)FROM Issue) AS 'top_callers'
          FROM(
            SELECT ROW_NUMBER() OVER(ORDER BY t.my_calls DESC) AS row, t.* 
            
              FROM(
                SELECT Issue.Caller_id, 
                     COUNT(*) AS my_calls        
                FROM Caller JOIN Issue ON Caller.Caller_id = Issue.Caller_id 
                GROUP BY 1) t --this table aggregagtes calls per caller 
          
              )t2 -- t2 ranks all callers 
      )t3 -- t3 shows percentage ranking of all callers 
      WHERE t3.top_callers <= 20
)

-- #13
/*
Annoying customers. Customers who call in the last five minutes of a shift are annoying. Find the most active customer who has never been annoying.
*/

SELECT Company_name, COUNT(Call_ref) AS abna
  
  FROM Issue 
  JOIN Caller
    ON Issue.Caller_ID = Caller.Caller_ID 
  JOIN Customer
  ON Customer.Company_ref = Caller.Company_ref

  WHERE Customer.Company_ref NOT IN ( --subquery for companies that have been annoying 
        SELECT Company_ref
          FROM Issue
          JOIN Shift_type 
            ON HOUR(End_time)-1 = HOUR(Call_date) AND MINUTE(Call_date)>=55
          JOIN Caller 
            ON Caller.Caller_id = Issue.Caller_id)
            
GROUP BY 1
ORDER BY 2 desc

LIMIT 1

-- #14
/*
Maximal usage. If every caller registered with a customer makes a call in one day then that customer has "maximal usage" of the service. List the maximal customers for 2017-08-13.
*/

SELECT t2.Company_name, 
      COUNT(DISTINCT all_callers) AS caller_count, 
      COUNT(DISTINCT called) AS issue_count
  
  FROM(
    SELECT Company_name, 
           Caller.Caller_id AS all_callers, 
           t.caller_id AS called
      FROM Customer
      JOIN Caller
        ON Caller.Company_ref = Customer.Company_ref 
      LEFT JOIN -- All the customer's callers, ONTO callers on that day 
      (SELECT caller_id 
          FROM Issue
          WHERE Call_date LIKE '%2017-08-13%') t
        ON Caller.caller_id = t.caller_id 
    
     ORDER BY 1,2)AS t2

GROUP BY Company_name
HAVING caller_count = issue_count 

-- #15
/*
Consecutive calls occur when an operator deals with two callers within 10 minutes. Find the longest sequence of consecutive calls – give the name of the operator and the first and last call date in the sequence.Is
*/











