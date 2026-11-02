# 🛒 Mini-Market Relational Database

Relational database designed for a retail mini-market, featuring automated transaction calculations and strict data integrity constraints. Built as the final project for **CS50 SQL**.

## 🛠 Tech Stack
* **Database Engine:** SQLite
* **Language:** SQL (DDL, DML)

## ✨ Key Features
* **Normalized Schema:** 5 interconnected tables (`categories`, `products`, `customers`, `orders`, `order_items`).
* **Data Integrity:** Enforced via `FOREIGN KEY`, `CHECK`, and `UNIQUE` constraints.
* **Automated Business Logic:** Triggers to lock historical unit prices and automatically recalculate order total amounts.
* **Performance:** Explicit indexing on foreign keys for query optimization.

## 📄 Architectural Details
For a deep dive into database design decisions, entity-relationship trade-offs, and trigger architecture, please read the full [DESIGN.md](DESIGN.md).

## 🚀 Quick Start
1. Clone the repository.
2. Load the schema into SQLite:
   ```sql
   .read schema.sql
