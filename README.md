# Fleet-management-

## Overview

This project implements an object-relational database in **Oracle** for managing a car fleet. The goal is to optimize and automate vehicle management for companies with large fleets. The project demonstrates the application of **data modeling**, **PL/SQL programming**, and **database operations** in a real-world scenario.

---

## Features

* **Data Modeling**:

  * Object types for addresses, clients, drivers, vehicles, rentals, maintenance, and inspections.
  * Nested tables to store collections such as vehicle mileage, maintenance, and technical inspections.
* **Database Tables**:

  * `ADRESSES`, `CLIENTS`, `CONDUCTEURS`, `VEHICULES`, `LOUER`.
  * Constraints for data integrity (primary keys, unique constraints, check constraints).
* **PL/SQL Procedures and Functions**:

  * Add or remove clients.
  * Count available vehicles.
  * Retrieve driver city/region.
* **Triggers**:

  * Notifications for belt replacements, oil changes, technical inspections, and contract deadlines.

---

## Installation

1. **Create Types and Tables**: Execute the SQL scripts for object types and relational tables.
2. **Insert Sample Data**: Populate tables with sample clients, vehicles, drivers, and rental contracts.
3. **Add PL/SQL Functions and Triggers**: Implement the provided procedures, functions, and triggers to automate fleet management tasks.

---

## Usage

* **Monitor vehicle maintenance**: Triggers automatically alert for upcoming belt replacements, oil changes, and technical inspections.
* **Check rentals**: Queries can find delayed contracts or clients exceeding mileage limits.


## Conclusion

This project demonstrates the full cycle of **object-relational database design and implementation** in Oracle for fleet management. It emphasizes the use of **object types**, **nested tables**, **references**, **PL/SQL functions/procedures**, and **triggers** to handle real-world business operations efficiently.


