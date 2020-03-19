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
*/

