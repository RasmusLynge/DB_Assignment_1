# DB_Assignment_1
*Mathias, Magnus og Rasmus*


## ER diagram: 
![Diagram picture](https://github.com/RasmusLynge/DB_Assignment_1/blob/main/ER_diagram.png)


## Implementation  
The code part of the assignment is written purely for proof of concept - therefore everything is written statically in a main class.  It is a simple maven project, containing only the necessary JDBC dependency. Consequently it should be relatively easy to run it against a local Postgres database. 
The `insertPet()`method makes use of the `insert_pet` procedure from the sql script, and the `printAllPets()` uses the view "PETS". The SQL script is reentrant and it includes insertion of sample data matching the specifications in the assignment.  

Further versions of the Java program could include Java classes that correspond to the database tables, complete with inheritance, and usage of a persistence framework for easier handling.


## Java program  
Clone this project to run the java program.
You might have to change the credentials to run the script on your database. (line 22 and 53 in [main java class](https://github.com/RasmusLynge/DB_Assignment_1/blob/main/src/main/java/Main.java))


## Database script  
The database script contains tables, sample data and a user role  
[The script can be found here](https://github.com/RasmusLynge/DB_Assignment_1/blob/main/SCRIPT.sql)  

The user created with the script:  
- username: bruger  
- password: bruger  
  
You might have to change the schema (line 222) if you run the script elsewhere.  


## Inheritance strategy  
#### Joint-table strategy 
Pros:  
-  Follows Data Normalization
Cons:
- Runtime updates (the update of one table will lock other tables - can be slow)


#### Table-per-class strategy  
Pros:  
-  insert, delete, update is simple. (only working on one table)
Cons:
- New table for each animal type.
- polymorphism from object oriented programming does not work well with this strategy.


#### Single-table strategy  
Pros:  
- Fastest of all the inheritance strategy - no need for joins, only needs one insert or update.  
- simple queries
  
Cons:  
- Redundant data.  
- Does not follow Data Normalization
