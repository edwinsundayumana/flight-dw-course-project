/*
    Phase 1 - Preprocessing
    Final consolidated check of every preprocessing requirement,
    run together in one pass so the results can be captured as a
    single piece of evidence for the report.

    Expected results (as of the last run of this project):
    DepartureAirports_Need20   = 30  (>= 20 required)
    LandingAirports_Need20     = 30  (>= 20 required)
    TransitRows_Need20         = 25  (>= 20 required)
    DistinctPassengers_Need50  = 600 (>= 50 required)
    DistinctAirlines_Need10    = 12  (>= 10 required)
    BlankPlanes_MustBe0        = 0
    DistinctPlanes_MustBeMoreThan1 = 18
    SameAirportRows_MustBe0    = 0
    EarliestFlightDate         = 2021-01-17
    LatestFlightDate           = 2021-07-15  (~6 month span)
*/

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
