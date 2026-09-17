INSERT INTO hotel_bookings (
    id,
    org_id,
    hotel_id,
    city,
    checkin_date,
    checkout_date,
    amount,
    status,
    created_at
)
SELECT
    gen_random_uuid(),
    CASE g % 4
        WHEN 0 THEN '11111111-1111-1111-1111-111111111111'::uuid
        WHEN 1 THEN '22222222-2222-2222-2222-222222222222'::uuid
        WHEN 2 THEN '33333333-3333-3333-3333-333333333333'::uuid
        ELSE '44444444-4444-4444-4444-444444444444'::uuid
    END,
    'HOTEL-' || LPAD(((g % 25) + 1)::text, 3, '0'),
    CASE g % 6
        WHEN 0 THEN 'delhi'
        WHEN 1 THEN 'mumbai'
        WHEN 2 THEN 'bengaluru'
        WHEN 3 THEN 'pune'
        WHEN 4 THEN 'hyderabad'
        ELSE 'jaipur'
    END,
    CURRENT_DATE + ((g % 90) + 1),
    CURRENT_DATE + ((g % 90) + 3),
    ROUND((150 + (g * 37.25))::numeric, 2),
    CASE g % 5
        WHEN 0 THEN 'confirmed'
        WHEN 1 THEN 'pending'
        WHEN 2 THEN 'cancelled'
        WHEN 3 THEN 'completed'
        ELSE 'failed'
    END,
    NOW() - ((g % 60) || ' days')::interval - ((g % 24) || ' hours')::interval
FROM generate_series(1, 200) AS g;

INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT
    b.id,
    'created',
    jsonb_build_object('source', 'seed', 'city', b.city, 'status', b.status),
    b.created_at
FROM (
    SELECT id, city, status, created_at
    FROM hotel_bookings
    ORDER BY created_at DESC
    LIMIT 20
) AS b
UNION ALL
SELECT
    b.id,
    'status_changed',
    jsonb_build_object('source', 'seed', 'new_status', b.status),
    b.created_at + INTERVAL '1 hour'
FROM (
    SELECT id, status, created_at
    FROM hotel_bookings
    ORDER BY created_at DESC
    LIMIT 20
) AS b;
