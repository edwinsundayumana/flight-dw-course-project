/*
    Phase 1 - Preprocessing
    Requirement (course project spec): >=20 of the fact rows should
    represent a flight with a stopover/transit airport. This field
    does not exist in the original dataset -- the assignment
    explicitly instructs students to supplement it themselves.
    Problem found: Transit_ariportID was 100% blank.

    Fix: reuse the same 30-airport pool from script 02, with a third
    shift value (7) for transit. Since none of the three shifts
    (0 departure, 15 landing, 7 transit) share a common factor with
    the pool size of 30, all three airports are guaranteed different
    on every row, by construction -- no row-by-row checking needed.

    Only ~1 in 24 rows receives a transit airport (25 of 600), spread
    evenly across the whole dataset rather than clustered, to look
    like a realistic small subset of flights with layovers.
*/

USE FlightDW;
GO

DECLARE @PoolSize INT = 30;
DECLARE @TransitOffset INT = 7;

;WITH AirportPool AS (
    SELECT TOP (@PoolSize) AirportID,
           ROW_NUMBER() OVER (ORDER BY AirportID) AS AirportRank
    FROM DimAirport
    ORDER BY AirportID
),
FactNumbered AS (
    SELECT ian, ROW_NUMBER() OVER (ORDER BY ian) AS RowNum
    FROM FactAirticket
)
UPDATE f
SET f.Transit_ariportID = t.AirportID
FROM FactAirticket f
JOIN FactNumbered fn ON f.ian = fn.ian
JOIN AirportPool t ON t.AirportRank = ((fn.RowNum - 1 + @TransitOffset) % @PoolSize) + 1
WHERE fn.RowNum % 24 = 0;
GO

-- Verify
SELECT COUNT(*) AS RowsWithTransit
FROM FactAirticket
WHERE Transit_ariportID IS NOT NULL;

SELECT COUNT(*) AS BadRows
FROM FactAirticket
WHERE Transit_ariportID IS NOT NULL
  AND (Transit_ariportID = Departure_ariportID OR Transit_ariportID = Landing_ariportID);
