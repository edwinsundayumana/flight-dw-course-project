/*
    Phase 1 - Preprocessing
    Requirement: >=20 distinct departure airports, >=20 distinct landing
    airports, and departure must never equal landing on the same row.
    Problem found: only 2 airports were ever used (IDs 22 and 74).

    Fix: pick a pool of 30 airports from DimAirport (comfortably above
    the required 20). Assign departure by round-robin cycling through
    the pool. Assign landing the same way but shifted by 15 (half the
    pool size) -- since 15 is not a multiple of 30, departure and
    landing can mathematically never land on the same pool position,
    guaranteed for every row.
*/

USE FlightDW;
GO

DECLARE @PoolSize INT = 30;
DECLARE @Offset INT = 15;

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
SET f.Departure_ariportID = dep.AirportID,
    f.Landing_ariportID = land.AirportID
FROM FactAirticket f
JOIN FactNumbered fn ON f.ian = fn.ian
JOIN AirportPool dep  ON dep.AirportRank  = ((fn.RowNum - 1) % @PoolSize) + 1
JOIN AirportPool land ON land.AirportRank = ((fn.RowNum - 1 + @Offset) % @PoolSize) + 1;
GO

-- Verify
SELECT COUNT(DISTINCT Departure_ariportID) AS DepDistinct,
       COUNT(DISTINCT Landing_ariportID) AS LandDistinct
FROM FactAirticket;

SELECT COUNT(*) AS RowsWhereSameAirport
FROM FactAirticket
WHERE Departure_ariportID = Landing_ariportID;
