-- #1
/*
Guest 1183. Give the booking_date and the number of nights for guest 1183.
*/

SELECT DATE_FORMAT(booking_date, "%Y-%m-%d") AS booking_date, nights 
  FROM booking
WHERE guest_id = 1183


-- #2
/*
When do they get here? List the arrival time and the first and last names for all guests due to arrive on 2016-11-05, order the output by time of arrival.
*/

SELECT arrival_time, first_name, last_name
  FROM booking 
  JOIN guest
    ON guest.id = booking.guest_id 
  WHERE booking_date LIKE '%2016-11-05%'
ORDER BY 1

-- #3
/*
Look up daily rates. Give the daily rate that should be paid for bookings with ids 5152, 5165, 5154 and 5295. Include booking id, room type, number of occupants and the amount.
*/

SELECT booking_id, room_type_requested, occupants, amount
  FROM booking
  JOIN rate
    ON booking.room_type_requested = rate.room_type 
  AND booking.occupants = rate.occupancy
  WHERE booking_id IN ('5152','5165','5154','5295')

-- #4
/*
Who’s in 101? Find who is staying in room 101 on 2016-12-03, include first name, last name and address.
*/

SELECT first_name, last_name, address
  FROM booking
  JOIN guest
    ON booking.guest_id = guest.id
WHERE room_no = '101' AND booking_date LIKE '%2016-12-03%'

-- #5
/*
How many bookings, how many nights? For guests 1185 and 1270 show the number of bookings made and the total number nights. Your output should include the guest id and the total number of bookings and the total number of nights.
*/

SELECT guest_id, COUNT(booking_id) AS n_bookings, SUM(nights) AS n_nights
  FROM booking
  WHERE guest_id IN ('1185','1270')
GROUP BY 1

-- #6
/*
Ruth Cadbury. Show the total amount payable by guest Ruth Cadbury for her room bookings. You should JOIN to the rate table using room_type_requested and occupants.
*/

SELECT SUM(amount*nights) AS bill 
  FROM booking 
    JOIN rate 
      ON rate.room_type = booking.room_type_requested
     AND rate.occupancy = booking.occupants
    JOIN guest
      ON booking.guest_id = guest.id

  WHERE first_name = 'Ruth' AND last_name = 'Cadbury'


SELECT SUM(t.amount_due) AS bill
  FROM
    (SELECT booking_id, SUM(rate.amount*nights) AS amount_due
      FROM booking 
        JOIN rate 
          ON rate.room_type = booking.room_type_requested
         AND rate.occupancy = booking.occupants
         WHERE booking_id = '5346'
    
    UNION

    SELECT booking_id, amount AS amount_due
      FROM extra WHERE booking_id = '5346') AS t

-- #8
/*
Edinburgh Residents. For every guest who has the word “Edinburgh” in their address show the total number of nights booked. Be sure to include 0 for those guests who have never had a booking. Show last name, first name, address and number of nights. Order by last name then first name.
*/

SELECT last_name, first_name, address, COALESCE(SUM(nights),0)
  FROM booking 
    RIGHT JOIN guest
            ON booking.guest_id = guest.id
    WHERE address LIKE '%Edinburgh%'
GROUP BY 1,2,3
ORDER BY 1,2

-- #9
/*
Show the number of people arriving. For each day of the week beginning 2016-11-25 show the number of people who are arriving that day.
*/

SELECT booking_date, COUNT(booking_id)
  FROM booking
  WHERE booking_date BETWEEN '2016-11-25' AND DATE_ADD('2016-11-25', INTERVAL 6 DAY)
GROUP BY 1

-- #10
/*
How many guests? Show the number of guests in the hotel on the night of 2016-11-21. Include all those who checked in that day or before but not those who have check out on that day or before.
*/

SELECT SUM(occupants)
  FROM booking
WHERE '2016-11-21' BETWEEN booking_date AND booking_date + nights - 1

-- #11
/*
Coincidence. Have two guests with the same surname ever stayed in the hotel on the evening? Show the last name and both first names. Do not include duplicates.

(StartA <= EndB) and (EndA >= StartB)

Proof:
Let ConditionA Mean that DateRange A Completely After DateRange B
_                        |---- DateRange A ------| 
|---Date Range B -----|                           _
(True if StartA > EndB)

Let ConditionB Mean that DateRange A is Completely Before DateRange B
|---- DateRange A -----|                       _ 
 _                          |---Date Range B ----|
(True if EndA < StartB)

Then Overlap exists if Neither A Nor B is true -
(If one range is neither completely after the other,
nor completely before the other, then they must overlap.)

Now one of De Morgan's laws says that:

Not (A Or B) <=> Not A And Not B

Which translates to: (StartA <= EndB)  and  (EndA >= StartB)
*/

SELECT DISTINCT last_name, g1_first_name, g2_first_name
  FROM(
    SELECT g1.last_name AS last_name, g2.last_name AS dup_last_name, 
          g1.first_name AS g1_first_name, x.booking_id AS x_id, 
          x.booking_date AS g1_beg, x.nights AS x_nights, 
          DATE_ADD(x.booking_date-1, INTERVAL x.nights DAY) AS g1_end,

          g2.first_name AS g2_first_name, y.booking_id AS y_id, 
          y.booking_date AS g2_beg, y.nights AS y_nights, 
          DATE_ADD(y.booking_date-1, INTERVAL y.nights DAY) AS g2_end

      FROM booking x
      JOIN guest g1
        ON x.guest_id = g1.id 
      JOIN guest g2
        ON g1.last_name = g2.last_name AND g1.first_name > g2.first_name
      JOIN booking y
        ON y.guest_id = g2.id

      ORDER BY 1)AS t

WHERE t.g1_beg<=t.g2_end AND t.g1_end>=t.g2_beg
ORDER BY 1

-- #12
/*
Check out per floor. The first digit of the room number indicates the floor – e.g. room 201 is on the 2nd floor. For each day of the week beginning 2016-11-14 show how many guests are checking out that day by floor number. Columns should be day (Monday, Tuesday ...), floor 1, floor 2, floor 3.
*/

SELECT DATE_ADD(booking_date, INTERVAL nights DAY) AS checkout,
    COUNT(CASE WHEN room_no LIKE '1%' THEN 1 ELSE NULL END) AS "1st",
    COUNT(CASE WHEN room_no LIKE '2%' THEN 1 ELSE NULL END) AS "2nd",
    COUNT(CASE WHEN room_no LIKE '3%' THEN 1 ELSE NULL END) AS "2nd"

  FROM booking

  WHERE DATE_ADD(booking_date, INTERVAL nights DAY) BETWEEN '2016-11-14' AND DATE_ADD('2016-11-14', INTERVAL 6 DAY)
  GROUP BY 1

-- #13
/*
 Free rooms? List the rooms that are free on the day 25th Nov 2016. 
 */

SELECT room.id
  FROM room
  LEFT JOIN booking
         ON room.id = booking.room_no 
          AND '2016-11-25' BETWEEN booking_date AND 
                          DATE_ADD(booking_date, INTERVAL (nights-1) DAY)
  WHERE booking_date IS NULL 

-- #14
/*
 Single room for three nights required. A customer wants a single room for three consecutive nights. 
 Find the first available date in December 2016.
 */

WITH subquery AS( -- existing single-bed bookings in Dec 
     SELECT room_no, booking_date, 
            DATE_ADD(booking_date, INTERVAL (nights-1) DAY) AS last_night
       FROM booking
       WHERE room_type_requested='single' AND
             DATE_ADD(booking_date, INTERVAL (nights-1) DAY)>='2016-12-1' AND 
             booking_date <='2016-12-31'
       ORDER BY room_no, last_night) 

SELECT room_no, MIN(first_avail) AS first_avail
FROM( 
  
-- check the last date the room is booked in December (available after)
   
SELECT room_no, MIN(first_avail) AS first_avail
  FROM(
      SELECT room_no, DATE_ADD(MAX(last_night), INTERVAL 1 DAY) AS first_avail
        FROM subquery q3
        GROUP BY 1
        ORDER BY 2) AS t2

UNION 

-- check if any 3-day exist in between reservations 

SELECT room_no, DATE_ADD(MIN(end2), INTERVAL 1 DAY) AS first_avail
  FROM(
      SELECT q1.booking_date AS beg1, q1.room_no, q1.last_night AS end1, 
             q2.booking_date AS beg2, q2.last_night AS end2
        FROM subquery q1
        JOIN subquery q2 
          ON q1.room_no = q2.room_no AND q2.booking_date > q1.last_night
      GROUP BY 2,1
      ORDER BY 2,1) AS t
      WHERE beg2-end1 > 3) AS inner_t

-- #15
/*
Gross income by week. Money is collected from guests when they leave. For each Thursday in November and December 2016, 
show the total amount of money collected from the previous Friday to that day, inclusive. 
-- solutions given is daily... 

*/

SELECT checkout, SUM(bill) AS daily_income
  FROM(
      SELECT booking.booking_id, 
             (amount*nights + t.extra_charge) AS bill, 
             DATE_ADD(booking_date, INTERVAL nights DAY) AS checkout
        FROM booking
        JOIN rate
          ON rate.room_type = booking.room_type_requested
        JOIN (SELECT booking_id, SUM(amount) AS extra_charge
                FROM extra
                GROUP BY 1) AS t
          ON t.booking_id = booking.booking_id) AS individual
GROUP BY checkout


