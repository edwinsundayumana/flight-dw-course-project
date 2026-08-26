/*
    Phase 1 - Preprocessing
    Follow-up to script 04. Re-runs the ticket assignment now that
    DimTicket contains real flights for 12 airlines instead of 7
    (5 original real airlines, wait -- 7 real + 5 synthetic = 12).

    Builds a pool of the first 5 tickets per airline (12 airlines x
    5 tickets = 60-ticket pool), then round-robin assigns TicketID
    across all 600 fact rows, same technique as PlaneID and airports.
*/

USE FlightDW;
GO

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
GO

-- Verify
SELECT COUNT(DISTINCT LEFT(t.FlightNo, 2)) AS DistinctAirlines
FROM FactAirticket f
JOIN DimTicket t ON f.TicketID = t.TicketID;

SELECT LEFT(t.FlightNo, 2) AS AirlineCode, COUNT(*) AS FlightsAssigned
FROM FactAirticket f
JOIN DimTicket t ON f.TicketID = t.TicketID
GROUP BY LEFT(t.FlightNo, 2)
ORDER BY AirlineCode;
