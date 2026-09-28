# Lecture 1 Notes

## Assumption that may change later

The current model assumes that a trip only needs one scheduled departure timestamp.

It does not store scheduled arrival and departure times for every stop on the route.

A later version may therefore need an additional relation such as `trip_stops` or `stop_times` containing stop-specific arrival and departure times.