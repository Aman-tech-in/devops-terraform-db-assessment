SELECT 'hotel_bookings' AS table_name, COUNT(*) AS row_count FROM hotel_bookings
UNION ALL
SELECT 'booking_events', COUNT(*) FROM booking_events;

SELECT city, COUNT(*) AS booking_count
FROM hotel_bookings
GROUP BY city
ORDER BY city;

SELECT status, COUNT(*) AS booking_count
FROM hotel_bookings
GROUP BY status
ORDER BY status;
