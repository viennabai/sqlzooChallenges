-- #1
/*
Give the room id in which the event co42010.L01 takes place.
*/

SELECT room 
  FROM event
  WHERE id = 'co42010.L01'

-- #2
/*
For each event in module co72010 show the day, the time and the place.
*/

SELECT dow, tod, room 
  FROM event 
  WHERE modle = 'co72010 '

-- #3
/*
List the names of the staff who teach on module co72010.
*/

SELECT event.id, staff.name
  FROM event 
  JOIN teaches 
    ON event.id = teaches.event
  JOIN staff 
    ON teaches.staff = staff.id
  WHERE event.modle = 'co72010'

-- #4
/*
Give a list of the staff and module number associated with events using room cr.132 on Wednesday, include the time each event starts.
*/

SELECT event.modle, staff.name, event.tod
  FROM event 
  JOIN teaches 
    ON event.id = teaches.event
  JOIN staff 
    ON teaches.staff = staff.id
  WHERE dow = 'Wednesday' AND room = 'cr.132'

-- #5
/*
Give a list of the student groups which take modules with the word 'Database' in the name.
*/

SELECT DISTINCT student.name AS student
  FROM modle
  JOIN event
    ON modle.id = event.modle 
  JOIN attends
    ON event.id = attends.event
  JOIN student
    ON attends.student=student.id
  WHERE modle.name LIKE '%Database%'

-- #6
/*
Show the 'size' of each of the co72010 events. Size is the total number of students attending each event.
*/

SELECT attends.event, SUM(student.sze) AS attendance 
  FROM event
  JOIN attends 
    ON event.id = attends.event
  JOIN student
    ON student.id = attends.student
  WHERE event.modle = 'co72010'
  
  GROUP BY 1

-- #7
/*
For each post-graduate module, show the size of the teaching team. (post graduate modules start with the code co7).
*/

SELECT event.modle, COUNT(DISTINCT staff) AS teaching_team
  FROM event
  JOIN teaches 
    ON event.id = teaches.event
  WHERE modle LIKE 'co7%'
 
 GROUP BY 1

-- #8
/*
Give the full name of those modules which include events taught for fewer than 10 weeks.
*/

SELECT DISTINCT modle.name
  FROM event
  JOIN occurs
    ON event.id = occurs.event
  JOIN modle
    ON modle.id = event.modle 
  
  GROUP BY occurs.event
  HAVING COUNT(occurs.week) < 10 
  ORDER BY 1

-- #9
/*
Identify those events which start at the same time as one of the co72010 lectures.
*/

SELECT a.dow, a.tod, b.id
  FROM event a
  JOIN event b
    ON a.dow = b.dow AND a.tod = b.tod AND a.modle != b.modle
  WHERE a.modle = 'co72010 '
  
  ORDER BY 1,2 

-- #10 _________________________*****************
/*
How many members of staff have contact time which is greater than the average?
*/


SELECT SUM(contact_time)/COUNT(staff) AS avg_contact_time
FROM(
SELECT staff, SUM(duration) AS contact_time 
FROM teaches 
JOIN event 
ON teaches.event = event.id
GROUP BY 1
ORDER BY 1) AS t1

-- #11
/*
co.CHt is to be given all the teaching that co.ACg currently does. Identify those events which will clash.
*/

SELECT acg.event, cht.event
  FROM(
  
    SELECT staff, teaches.event, dow, tod, duration
      FROM teaches
      JOIN event
        ON event = event.id
      WHERE staff = 'co.ACg') as acg

    JOIN(
    
    SELECT staff, teaches.event, dow, tod, duration
      FROM teaches
      JOIN event
        ON event = event.id
      WHERE staff = 'co.CHt') AS cht

    ON acg.dow = cht.dow 

    WHERE acg.tod < (cht.tod+cht.duration) AND (acg.tod+acg.duration) > cht.tod
    
    ORDER BY acg.dow, acg.tod

-- #12
/*
Produce a table showing the utilisation rate and the occupancy level for all rooms 
with a capacity more than 60.

#note - only one room has capacity > 60
*/

SELECT event.id, dow, tod, SUM(sze) AS attendance, room
  FROM event
  JOIN attends
    ON event.id = attends.event
  JOIN student
    ON attends.student = student.id
  WHERE room IN (SELECT id
                  FROM room 
                  WHERE capacity > 60)
  GROUP BY 1
  ORDER BY 2,3













