-- Query 1: next 20 scheduled trips for a route
-- after a supplied timestamp.

select
    t.id,
    t.scheduled_departure_utc,
    t.status
from trips t
where t.route_id = :route_id
  and t.scheduled_departure_utc >= :after_utc
order by t.scheduled_departure_utc
limit 20;


-- Query 2: ordered stops belonging to a route.

select
    s.id,
    s.name,
    rs.stop_sequence
from route_stops rs
join stops s
    on s.id = rs.stop_id
where rs.route_id = :route_id
order by rs.stop_sequence;


-- Query 3: all routes and number of scheduled trips
-- for a supplied service date, including routes with zero trips.

select
    r.id,
    r.short_name,
    count(t.id) as trip_count
from routes r
left join trips t
    on t.route_id = r.id
   and t.service_date = :service_date
group by
    r.id,
    r.short_name
order by r.id;