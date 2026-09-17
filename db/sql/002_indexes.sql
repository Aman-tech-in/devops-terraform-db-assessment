-- The query filters by city and a created_at range, then reads org_id/status/amount.
-- Leading WHERE columns are indexed; selected/grouping columns are INCLUDE columns
-- so PostgreSQL can consider an index-only scan and avoid heap reads where possible.
CREATE INDEX IF NOT EXISTS idx_hotel_bookings_city_created_at
    ON hotel_bookings (city, created_at)
    INCLUDE (org_id, status, amount);

CREATE INDEX IF NOT EXISTS idx_booking_events_booking_id
    ON booking_events (booking_id);
