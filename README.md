# MobilityTicketing: Lecture 1 starter

This repository is the starter code for the first lecture. It contains a small PostgreSQL slice for route maintenance and timetable queries.

The exercise is intentionally incomplete. Add the route-stop key, complete the seed data, write the three workload queries, and follow the lab brief in `docs/lab.md`.

## Start the database

Requirements:

- Docker Desktop with Compose

Start PostgreSQL:

```bash
docker compose up -d
```

The database is available at `localhost:5432` with database `mobility`, user `mobility`, and password `mobility`.

To stop it:

```bash
docker compose down
```

The starter seed loads operators, routes, and stops. Complete `database/postgres/002_seed.sql` with route-stop rows and trips after deciding on the route-stop primary key. The initialization scripts run only when PostgreSQL starts with an empty data directory, so rebuild the container when you need to replay them:

```bash
docker compose down -v
docker compose up -d
```

## Your tasks

1. Add primary-key and foreign-key relationships where needed.
2. Decide whether a route may visit the same stop more than once, and explain the choice.
3. Add at least two trips per route on the same service date.
4. Complete the three query skeletons.
5. Compare the SQL model with your ER diagram.
6. Record one assumption that may change later in `docs/notes.md`.

Do not add MongoDB, Redis, queues, payment logic, validation logic, reporting tables, or performance indexes in this first slice.

## Files

- `compose.yaml`: PostgreSQL starter infrastructure.
- `database/postgres/001_relational_baseline.sql`: incomplete relational schema.
- `database/postgres/002_seed.sql`: repeatable starter seed with TODOs.
- `database/postgres/003_queries.sql.example`: query skeleton for the three released workloads.
- `docs/lab.md`: student-facing lab brief and submission checklist.

The sample solution is intentionally not included in this repository.

---

# Submission

## System context

The Mobility Ticketing system supports customers travelling by bus,
tram, and train in a city.

Customers can search for routes and departures, purchase tickets,
and validate tickets when boarding.

Transport operators maintain routes, stops, timetables, products,
and prices, and use historical ticketing information for reporting.

The Lecture 1 implementation only models the route and timetable
portion of the system.

## Access-pattern map

| Workload | Main data required | Characteristics |
|---|---|---|
| Journey search | Routes, stops, trips, prices, availability | Read-heavy and latency-sensitive |
| Ticket purchase | Trips, products, tickets, payments, capacity | Correctness-critical |
| Ticket validation | Tickets and validations | Latency-sensitive |
| Timetable maintenance | Routes, route stops and trips | Operator write workload |
| Real-time availability | Trips and remaining capacity | Read much more frequently than updated |
| Reporting | Tickets, payments and validations | Can tolerate delayed data |

Only route maintenance and scheduled-trip queries are implemented
during Lecture 1.

## Route-stop primary key

The primary key of `route_stops` is:

`(route_id, stop_sequence)`

The stop sequence identifies a particular occurrence of a stop on a route.

This model allows the same physical stop to occur more than once on
the same route. This is useful for routes that loop or revisit a stop.

Using `(route_id, stop_id)` as the primary key would prevent the same
stop from appearing more than once on a route.

## Functional dependency

For the `routes` relation:

`route_id -> operator_id, city_id, mode, short_name`

A route identifier uniquely determines the operator, city, mode,
and short name of that route.

Operators are stored separately from routes. This avoids repeating
operator information for every route and reduces update anomalies.

## ER diagram

```mermaid
erDiagram
    OPERATORS ||--o{ ROUTES : operates
    ROUTES ||--o{ ROUTE_STOPS : contains
    STOPS ||--o{ ROUTE_STOPS : appears_in
    ROUTES ||--o{ TRIPS : schedules

    OPERATORS {
        text id PK
        text name
    }

    ROUTES {
        text id PK
        text operator_id FK
        text city_id
        text mode
        text short_name
    }

    STOPS {
        text id PK
        text city_id
        text name
    }

    ROUTE_STOPS {
        text route_id PK,FK
        text stop_id FK
        integer stop_sequence PK
    }

    TRIPS {
        text id PK
        text route_id FK
        date service_date
        timestamptz scheduled_departure_utc
        text status
    }