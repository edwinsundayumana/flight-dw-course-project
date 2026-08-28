/*
    Phase 2 - Star Schema Design
    Declares the remaining foreign key relationships between
    FactAirticket and its dimension tables -- relationships that
    already existed correctly (verified in Phase 1) but were not
    yet formally enforced by SQL Server.

    Note the three separate constraints pointing at DimAirport
    (Departure, Transit, Landing) -- this is a "role-playing
    dimension": one dimension table serving three distinct roles
    in the fact table.

    Before running this, all 4 target dimensions (Ticket, Plane,
    Cabin, PriceRange) were checked for orphaned references and
    confirmed clean (0 orphans each) -- see verification query
    at the bottom of this file, which was run beforehand.
*/

USE FlightDW;
GO

ALTER TABLE FactAirticket
ADD CONSTRAINT FK_FactAirticket_DepartureAirport
FOREIGN KEY (Departure_ariportID) REFERENCES DimAirport(AirportID);

ALTER TABLE FactAirticket
ADD CONSTRAINT FK_FactAirticket_TransitAirport
FOREIGN KEY (Transit_ariportID) REFERENCES DimAirport(AirportID);

ALTER TABLE FactAirticket
ADD CONSTRAINT FK_FactAirticket_LandingAirport
FOREIGN KEY (Landing_ariportID) REFERENCES DimAirport(AirportID);

ALTER TABLE FactAirticket
ADD CONSTRAINT FK_FactAirticket_DepartureDate
FOREIGN KEY (DepartureDateID) REFERENCES DimDateRange(DateRangeID);

ALTER TABLE FactAirticket
ADD CONSTRAINT FK_FactAirticket_ArrivalDate
FOREIGN KEY (ArrivalDateID) REFERENCES DimDateRange(DateRangeID);

ALTER TABLE FactAirticket
ADD CONSTRAINT FK_FactAirticket_Ticket
FOREIGN KEY (TicketID) REFERENCES DimTicket(TicketID);

ALTER TABLE FactAirticket
ADD CONSTRAINT FK_FactAirticket_Plane
FOREIGN KEY (PlaneID) REFERENCES DimPlane(PlaneID);

ALTER TABLE FactAirticket
ADD CONSTRAINT FK_FactAirticket_Cabin
FOREIGN KEY (CabinID) REFERENCES DimSeat(CabinID);

ALTER TABLE FactAirticket
ADD CONSTRAINT FK_FactAirticket_PriceRange
FOREIGN KEY (PriceRangeID) REFERENCES DimPriceRange(PriceRangeID);
GO

-- Verify: should return 11 rows total (these 9, plus Airlines and Passenger
-- added in scripts 08 and 09)
SELECT CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'FactAirticket' AND CONSTRAINT_TYPE = 'FOREIGN KEY'
ORDER BY CONSTRAINT_NAME;
