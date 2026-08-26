SELECT COUNT(*) FROM DimAirport;
GO

SELECT TOP 10 * FROM DimAirport;
DROP TABLE DimAirport;
GO

SELECT TOP 10 * FROM DimAirport;
GO

SELECT TOP 10 * FROM DimAirlines;
GO

SELECT TOP 10 * FROM DimPlane;
GO

SELECT TOP 10 * FROM DimDateRange;
GO

SELECT TOP 10 * FROM DimDateRange ORDER BY DateRangeID;
SELECT MIN(Date) AS EarliestDate, MAX(Date) AS LatestDate FROM DimDateRange;
GO

SELECT TOP 10 * FROM DimPriceRange;
SELECT * FROM DimPriceRange ORDER BY PriceRangeID;
SELECT COUNT(*) FROM DimPriceRange;
GO

SELECT TOP 10 * FROM DimSeat;
SELECT COUNT(*) FROM DimSeat;
SELECT * FROM DimSeat WHERE CabinID IN (1, 325,1294);
SELECT CabinClass, COUNT(*) AS SeatCount FROM DimSeat GROUP BY CabinClass;
GO

-- DROP TABLE DimPassenger;
SELECT TOP 10 * FROM DimPassenger;
SELECT COUNT(*) AS TotalPassengers FROM DimPassenger;
SELECT COUNT(*) AS MissingNames FROM Dimpassenger Where PassengerName IS NULL;
GO

SELECT TOP 10 * FROM DimTicket;
SELECT COUNT(*) AS TotalTickets FROM DimTicket;
SELECT MIN(departureTime) AS Earliest, MAX(departureTime) AS Latest FROM DimTicket;


-- DROP TABLE IF EXISTS FactAirticket;

SELECT TOP 10 * FROM FactAirticket;
SELECT COUNT(*) AS TotaRows FROM FactAirticket;
SELECT COUNT(*) AS BlankPlanes FROM FactAirticket WHERE PlaneID IS NULL;
SELECT TOP 5 Rate FROM FactAirticket; 

-- Fixing the Rate column in the fact table to 2 decimal place
ALTER TABLE FactAirticket
ALTER COLUMN Rate DECIMAL(3,2);
-- verifying its fixed
SELECT TOP 5 Rate FROM FactAirticket;
SELECT DISTINCT Rate FROM FactAirticket ORDER BY Rate;

SELECT COLUMN_NAME,DATA_TYPE, NUMERIC_PRECISION, NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FactAirticket';
GO

-- fixing the planeID empty spaces

DECLARE @PlaneCount INT = (SELECT COUNT(*) FROM DimPlane);

;WITH FactNumbered AS (
    SELECT ian, ROW_NUMBER() OVER (ORDER BY ian) AS RowNum
    FROM FactAirticket
),
PlaneNumbered AS (
    SELECT PlaneID, ROW_NUMBER() OVER (ORDER BY PlaneID) AS PlaneRank
    FROM DimPlane
)
UPDATE f
SET f.PlaneID = p.PlaneID
FROM FactAirticket f
JOIN FactNumbered fn ON f.ian = fn.ian
JOIN PlaneNumbered p ON p.PlaneRank = ((fn.RowNum - 1) % @PlaneCount) + 1;
GO

SELECT PlaneID, COUNT(*) AS FlightsAssigned
FROM FactAirticket
GROUP BY PlaneID
ORDER BY PlaneID;
GO

SELECT COUNT(*) AS StillBlank FROM FactAirticket WHERE PlaneID IS NULL;
GO

-- fixing the aspect of airports in the departureID and landingairportID
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

SELECT COUNT(DISTINCT Departure_ariportID) AS DepDistinct,
       COUNT(DISTINCT Landing_ariportID) AS LandDistinct
FROM FactAirticket;

SELECT COUNT(*) AS RowsWhereSameAirport
FROM FactAirticket
WHERE Departure_ariportID = Landing_ariportID;
GO

-- fixing the aspect of transit

DECLARE @PoolSize INT = 30;
DECLARE @LandOffset INT = 15;
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

-- verifying
SELECT COUNT(*) AS RowsWithTransit
FROM FactAirticket
WHERE Transit_ariportID IS NOT NULL;

SELECT COUNT(*) AS BadRows
FROM FactAirticket
WHERE Transit_ariportID IS NOT NULL
  AND (Transit_ariportID = Departure_ariportID OR Transit_ariportID = Landing_ariportID);
  GO

  -- fixing the airline adversity

DECLARE @PoolSize INT = 90;

;WITH RankedTickets AS (
    -- Step A: for every ticket, figure out which airline it belongs to,
    -- and number each airline's tickets 1, 2, 3... so we can pick "the first 5"
    SELECT t.TicketID, a.AirlinesID,
           ROW_NUMBER() OVER (PARTITION BY a.AirlinesID ORDER BY t.TicketID) AS RankWithinAirline
    FROM DimTicket t
    JOIN DimAirlines a ON LEFT(t.FlightNo, 2) = a.airlinesCode
),
TicketPool AS (
    -- Step B: keep only the first 5 tickets per airline (90 total),
    -- and give the whole pool a clean 1-to-90 numbering
    SELECT TicketID,
           ROW_NUMBER() OVER (ORDER BY AirlinesID, RankWithinAirline) AS PoolRank
    FROM RankedTickets
    WHERE RankWithinAirline <= 5
),
FactNumbered AS (
    -- Step C: same as always, number the 600 fact rows
    SELECT ian, ROW_NUMBER() OVER (ORDER BY ian) AS RowNum
    FROM FactAirticket
)
UPDATE f
SET f.TicketID = tp.TicketID
FROM FactAirticket f
JOIN FactNumbered fn ON f.ian = fn.ian
JOIN TicketPool tp ON tp.PoolRank = ((fn.RowNum - 1) % @PoolSize) + 1;
GO

-- verify
SELECT COUNT(DISTINCT LEFT(t.FlightNo, 2)) AS DistinctAirlines
FROM FactAirticket f
JOIN DimTicket t ON f.TicketID = t.TicketID;

SELECT LEFT(t.FlightNo, 2) AS AirlineCode, COUNT(*) AS FlightsAssigned
FROM FactAirticket f
JOIN DimTicket t ON f.TicketID = t.TicketID
GROUP BY LEFT(t.FlightNo, 2)
ORDER BY AirlineCode;

-- Checking 

USE FlightDW;
GO

SELECT a.AirlinesID, a.airlines, a.airlinesCode,
       COUNT(t.TicketID) AS MatchingTickets
FROM DimAirlines a
LEFT JOIN DimTicket t ON LEFT(t.FlightNo, 2) = a.airlinesCode
GROUP BY a.AirlinesID, a.airlines, a.airlinesCode
ORDER BY a.AirlinesID;

-- Inserted synthetic ticket rows
DECLARE @MaxID INT = (SELECT MAX(TicketID) FROM DimTicket);

INSERT INTO DimTicket (TicketID, departureTime, delayTime, arrivalTime, FlightNo)
SELECT @MaxID + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS TicketID,
       departureTime, delayTime, arrivalTime, FlightNo
FROM (VALUES
    ('2021-01-10 07:15:00', 5,  '2021-01-10 09:30:00', 'SC1234'),
    ('2021-02-14 12:00:00', 0,  '2021-02-14 14:20:00', 'SC5678'),
    ('2021-03-22 18:45:00', 20, '2021-03-22 21:10:00', 'SC4321'),
    ('2021-04-05 09:30:00', 10, '2021-04-05 11:50:00', 'SC8765'),
    ('2021-05-18 15:00:00', 0,  '2021-05-18 17:15:00', 'SC2468'),

    ('2021-01-12 06:30:00', 15, '2021-01-12 08:45:00', 'ZH1111'),
    ('2021-02-19 11:20:00', 0,  '2021-02-19 13:40:00', 'ZH2222'),
    ('2021-03-25 16:10:00', 25, '2021-03-25 18:35:00', 'ZH3333'),
    ('2021-04-09 08:00:00', 5,  '2021-04-09 10:15:00', 'ZH4444'),
    ('2021-05-21 13:45:00', 0,  '2021-05-21 16:00:00', 'ZH5555'),

    ('2021-01-15 05:50:00', 10, '2021-01-15 08:10:00', '3U8888'),
    ('2021-02-22 10:15:00', 0,  '2021-02-22 12:30:00', '3U7777'),
    ('2021-03-28 14:30:00', 30, '2021-03-28 17:00:00', '3U6666'),
    ('2021-04-12 07:40:00', 0,  '2021-04-12 09:55:00', '3U5555'),
    ('2021-05-24 19:00:00', 15, '2021-05-24 21:20:00', '3U4444'),

    ('2021-01-18 09:00:00', 0,  '2021-01-18 11:15:00', 'EU5201'),
    ('2021-02-25 13:30:00', 20, '2021-02-25 15:50:00', 'EU5202'),
    ('2021-03-31 17:15:00', 0,  '2021-03-31 19:35:00', 'EU5203'),
    ('2021-04-15 06:45:00', 10, '2021-04-15 09:00:00', 'EU5204'),
    ('2021-05-27 12:20:00', 0,  '2021-05-27 14:40:00', 'EU5205'),

    ('2021-01-21 08:10:00', 5,  '2021-01-21 10:25:00', '9C8865'),
    ('2021-02-28 12:50:00', 0,  '2021-02-28 15:05:00', '9C8866'),
    ('2021-04-02 16:40:00', 15, '2021-04-02 19:00:00', '9C8867'),
    ('2021-04-18 07:25:00', 0,  '2021-04-18 09:45:00', '9C8868'),
    ('2021-05-30 18:15:00', 20, '2021-05-30 20:35:00', '9C8869')
) AS x(departureTime, delayTime, arrivalTime, FlightNo);

-- verifying it works
SELECT LEFT(FlightNo, 2) AS AirlineCode, COUNT(*) AS TicketCount
FROM DimTicket
WHERE LEFT(FlightNo, 2) IN ('SC','ZH','3U','EU','9C')
GROUP BY LEFT(FlightNo, 2);
GO

USE FlightDW;
GO

-- redoing the ticket assignment so the fact table can pick up nex airlines
DECLARE @PoolSize INT = 60;

;WITH RankedTickets AS (
    SELECT t.TicketID, a.AirlinesID,
           ROW_NUMBER() OVER (PARTITION BY a.AirlinesID ORDER BY t.TicketID) AS RankWithinAirline
    FROM DimTicket t
    JOIN DimAirlines a ON LEFT(t.FlightNo, 2) = a.airlinesCode
),
TicketPool AS (
    SELECT TicketID,
           ROW_NUMBER() OVER (ORDER BY AirlinesID, RankWithinAirline) AS PoolRank
    FROM RankedTickets
    WHERE RankWithinAirline <= 5
),
FactNumbered AS (
    SELECT ian, ROW_NUMBER() OVER (ORDER BY ian) AS RowNum
    FROM FactAirticket
)
UPDATE f
SET f.TicketID = tp.TicketID
FROM FactAirticket f
JOIN FactNumbered fn ON f.ian = fn.ian
JOIN TicketPool tp ON tp.PoolRank = ((fn.RowNum - 1) % @PoolSize) + 1;

-- verifying
SELECT COUNT(DISTINCT LEFT(t.FlightNo, 2)) AS DistinctAirlines
FROM FactAirticket f
JOIN DimTicket t ON f.TicketID = t.TicketID;

SELECT LEFT(t.FlightNo, 2) AS AirlineCode, COUNT(*) AS FlightsAssigned
FROM FactAirticket f
JOIN DimTicket t ON f.TicketID = t.TicketID
GROUP BY LEFT(t.FlightNo, 2)
ORDER BY AirlineCode;

-- verying all the requirment in the assigned task is satisfied 
USE FlightDW;
GO

SELECT
    (SELECT COUNT(DISTINCT Departure_ariportID) FROM FactAirticket) AS DepartureAirports_Need20,
    (SELECT COUNT(DISTINCT Landing_ariportID) FROM FactAirticket) AS LandingAirports_Need20,
    (SELECT COUNT(*) FROM FactAirticket WHERE Transit_ariportID IS NOT NULL) AS TransitRows_Need20,
    (SELECT COUNT(DISTINCT PassengerID) FROM FactAirticket) AS DistinctPassengers_Need50,
    (SELECT COUNT(DISTINCT LEFT(t.FlightNo,2)) FROM FactAirticket f JOIN DimTicket t ON f.TicketID = t.TicketID) AS DistinctAirlines_Need10,
    (SELECT COUNT(*) FROM FactAirticket WHERE PlaneID IS NULL) AS BlankPlanes_MustBe0,
    (SELECT COUNT(DISTINCT PlaneID) FROM FactAirticket) AS DistinctPlanes_MustBeMoreThan1,
    (SELECT COUNT(*) FROM FactAirticket WHERE Departure_ariportID = Landing_ariportID) AS SameAirportRows_MustBe0,
    (SELECT MIN(d.Date) FROM FactAirticket f JOIN DimDateRange d ON f.DepartureDateID = d.DateRangeID) AS EarliestFlightDate,
    (SELECT MAX(d.Date) FROM FactAirticket f JOIN DimDateRange d ON f.DepartureDateID = d.DateRangeID) AS LatestFlightDate;

    -- downloading the new dataset of the facttable
    SELECT * FROM FactAirticket ORDER BY ian;