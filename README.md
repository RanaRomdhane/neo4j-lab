# Airlines Routes Graph Database
A Neo4j graph database project for analyzing global airline routes, airport connections, and flight patterns using real aviation data.

## 📊 Project Overview
This project models airline routes as a graph database where:

- Airports are nodes with geographic and operational data

- Airlines are nodes representing carriers

- Routes are relationships connecting airports via specific airlines and aircraft

## 🗄️ Data Model
```text
(Airport) <- [:from] - (Route) - [:to] -> (Airport)
                      |
                  [:by] -> (Airline)
```
## 📁 Data Sources
The project uses three main CSV files:

- airlines.csv - Airline company information

- airports.csv - Global airport data with coordinates

- routes.csv - Flight route information between airports

## 🚀 Quick Start
### Prerequisites
- Neo4j Desktop installed

- CSV files placed in Neo4j's import directory

### Installation
- Clone the repository

```bash
git clone https://github.com/RanaRomdhane/neo4j-lab.git
cd airlines-routes-neo4j
```
- Set up the database

- Copy CSV files to your Neo4j import folder

- Open Neo4j Browser

- Execute the setup script:

```cypher
// Run in Neo4j Browser
:source path/to/import_and_queries.cypher
```
Or run sections manually:

```cypher
// 1. Create indexes
CREATE INDEX FOR (a:Airport) ON (a.id);
CREATE INDEX FOR (a:Airline) ON (a.id);
CREATE INDEX FOR (a:Airport) ON (a.country);
// ... more indexes
```
```cypher
// 2. Load data
LOAD CSV WITH HEADERS FROM "file:///airlines.csv" AS l
CREATE (airline:Airline {id: toInteger(l.AirlineID), name: l.Name, country: l.Country, ...});
// ... more data loading
```
## 🔍 Example Queries
- Find Shortest Path Between Cities
```cypher
MATCH path = shortestPath((start:Airport {city: "Nantes"})-[:path*]->(end:Airport {city: "Salt Lake City"}))
RETURN path;
```
- Air France Routes by Country
```cypher
MATCH (:Airport)-[p:path {airline: "Air France"}]->(dest:Airport)
RETURN dest.country, COUNT(p) AS nb_routes
ORDER BY nb_routes DESC;
```
- A380 Operations from CDG
```cypher
MATCH (cdg:Airport {IATA: "CDG"})<-[:from]-(r:Route {equipment: "A380"})-[:to]->(dest)
RETURN dest.city, dest.country;
```
- French Domestic Routes
```cypher
MATCH (a1:Airport {country: "France"})-[p:path {airline: "Air France"}]->(a2:Airport {country: "France"})
RETURN a1, p, a2;
```
## 📈 Use Cases
- Route Planning: Find optimal connections between cities

- Airline Analysis: Analyze carrier route networks

- Aircraft Utilization: Track specific aircraft types

- Geographic Coverage: Map airline presence by country/region

- Connectivity Analysis: Identify hub airports and critical connections

## 🏗️ Project Structure
```text
neo4j-lab/
├── datasets/
│   ├── airlines.csv
│   ├── airports.csv
│   └── routes.csv
├── import_and_queries.cypher
└── README.md
```
## 🤝 Contributing
- Fork the repository

- Create a feature branch (git checkout -b feature/amazing-feature)

- Commit your changes (git commit -m 'Add amazing feature')

- Push to the branch (git push origin feature/amazing-feature)

- Open a Pull Request

## 🙏 Acknowledgments
- Flight route data from OpenFlights.org

- Neo4j for the graph database platform

- Aviation industry data providers

## 🛠️ Technical Details
Database: Neo4j Graph Database
Query Language: Cypher
Data Format: CSV
Key Features: Path finding, geographic analysis, network analysis
