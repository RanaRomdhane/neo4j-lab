// =============================================
// Neo4j Data Import and Query Script
// Created from command history
// =============================================

// Clean up existing data (optional - uncomment if needed)
// MATCH (n) DETACH DELETE n;

// =============================================
// STEP 1: Create indexes for better performance
// =============================================

CREATE INDEX FOR (a:Airport) ON (a.id);
CREATE INDEX FOR (a:Airline) ON (a.id);
CREATE INDEX FOR (a:Airport) ON (a.country);
CREATE INDEX FOR (a:Airport) ON (a.city);
CREATE INDEX FOR (a:Airport) ON (a.IATA);
CREATE INDEX FOR ()-[p:path]-() ON (p.airline);

// =============================================
// STEP 2: Load Airlines data
// =============================================

LOAD CSV WITH HEADERS FROM "file:/airlines.csv" AS l
CREATE (airline:Airline {
  id: toInteger(l.AirlineID),
  name: l.Name,
  alias: l.Alias,
  IATA: l.IATA,
  country: l.Country,
  active: l.Active
});

// =============================================
// STEP 3: Load Airports data
// =============================================

LOAD CSV WITH HEADERS FROM "file:/airports.csv" AS l
CREATE (airport:Airport {
  id: toInteger(l.AirportID),
  name: l.Name,
  city: l.City,
  country: l.Country,
  IATA: l.IATA,
  latitude: toFloat(l.Latitude),
  longitude: toFloat(l.Longitude),
  altitude: toFloat(l.Altitude),
  TimeZone: l.TZ
});

// =============================================
// STEP 4: Load Routes and create relationships
// =============================================

LOAD CSV WITH HEADERS FROM "file:/routes.csv" AS l
MERGE (airline:Airline {id: toInteger(l.AirlineID)})
MERGE (source:Airport {id: toInteger(l.SourceAirportID)})
MERGE (dest:Airport {id: toInteger(l.DestAirportID)})
CREATE (route:Route {equipment: l.Equipment})
CREATE (route)-[:from]->(source)
CREATE (route)-[:to]->(dest)
CREATE (route)-[:by]->(airline);

// =============================================
// STEP 5: Create path relationships for easier route queries
// =============================================

MATCH (FROM:Airport)<-[:from]-(r:Route)-[:to]->(TO:Airport), (r)-[:by]->(comp)
WHERE FROM <> TO
MERGE (FROM)-[p:path {airline: comp.name}]->(TO);

// =============================================
// STEP 6: Example queries from history
// =============================================

// Query 1: Shortest path between cities
MATCH path = shortestPath((start:Airport {city: "Nantes"})-[:path*]->(end:Airport {city: "Salt Lake City"}))
RETURN path;

// Query 2: Path with specific hop count
MATCH path = (start:Airport {city: "Nantes"})-[:path*2..3]->(end:Airport {city: "Salt Lake City"})
RETURN path;

// Query 3: Air France routes by country
MATCH (:Airport)-[p:path {airline: "Air France"}]->(dest:Airport)
RETURN dest.country, COUNT(p) AS nb_routes
ORDER BY nb_routes DESC;

// Query 4: Domestic Air France routes in France
MATCH (a1:Airport {country: "France"})-[p:path {airline: "Air France"}]->(a2:Airport {country: "France"})
RETURN a1, p, a2;

// Query 5: France to UK routes
MATCH (src:Airport {country: "France"})<-[:from]-(r:Route)-[:to]->(dest:Airport {country: "United Kingdom"})
RETURN src, r, dest;

// Query 6: A380 routes
MATCH (src)<-[:from]-(r:Route {equipment: "A380"})-[:to]->(dest)
RETURN src, r, dest;

// Query 7: CDG to French destinations
MATCH (cdg:Airport {IATA: "CDG"})<-[:from]-(r:Route)-[:to]->(dest:Airport {country: "France"})
RETURN cdg, r, dest;

// Query 8: Airlines operating A380 from CDG
MATCH (cdg:Airport {IATA: "CDG"})<-[:from]-(r:Route {equipment: "A380"})-[:by]->(comp)
RETURN DISTINCT comp.name;

// Query 9: A380 destinations from CDG
MATCH (cdg:Airport {IATA: "CDG"})<-[:from]-(r:Route {equipment: "A380"})-[:to]->(dest)
RETURN dest.city, dest.country;

// Query 10: All routes from CDG
MATCH (cdg:Airport {IATA: "CDG"})<-[:from]-(r:Route)-[:to]->(dest)
RETURN cdg, r, dest;

// Query 11: French airlines
MATCH (a:Airline {country: "France"})<-[:by]-(:Route)
RETURN DISTINCT a.name;

// Query 12: Active French airlines with IATA codes
MATCH (a:Airline {country: "France", active: "Y"})
WHERE a.IATA IS NOT NULL AND a.IATA <> ""
RETURN a.name, a.IATA;

// Query 13: French airports
MATCH (a:Airport {country: "France"})
RETURN a.name, a.IATA;