DROP TABLE IF EXISTS MESSAGES;
DROP TABLE IF EXISTS Vets CASCADE;
DROP TABLE IF EXISTS Caretakers CASCADE;
DROP TABLE IF EXISTS Addresses;
DROP TABLE IF EXISTS Cities;
DROP TABLE IF EXISTS pet_has_caretaker CASCADE;
DROP TABLE IF EXISTS CAT_DATA CASCADE;
DROP TABLE IF EXISTS DOG_DATA CASCADE;
DROP TABLE IF EXISTS PET_DATA;
---

-- tables
CREATE TABLE Cities (
    citycode int PRIMARY KEY NOT NULL,
    name varchar(20) NOT NULL
    );


CREATE TABLE Addresses (
    address_id SERIAL PRIMARY KEY,
    street varchar(100) NOT NULL,
    city_code int REFERENCES Cities NOT NULL
    );

CREATE TABLE Vets (
    vet_cvr char(8) PRIMARY KEY,
    name varchar(80) NOT NULL,
    address_id int REFERENCES Addresses
    );

CREATE TABLE Caretakers (
    caretaker_id SERIAL PRIMARY KEY,
    name varchar(80) NOT NULL,
	phone varchar(80) NOT NULL,
    address_id int REFERENCES Addresses
    );

CREATE TABLE PET_DATA (
	id SERIAL PRIMARY KEY,
	name varchar(20) NOT NULL,
	age int NOT NULL,
	vet_cvr char(8) REFERENCES VETs default NULL
	);
	
CREATE TABLE pet_has_caretaker (
	caretaker_id int REFERENCES Caretakers,
	id int REFERENCES PET_DATA
);

CREATE TABLE CAT_DATA (
	id int PRIMARY KEY REFERENCES PET_DATA NOT NULL,
	lifeCount int DEFAULT (9)
	);

CREATE TABLE DOG_DATA (
	id int PRIMARY KEY REFERENCES PET_DATA NOT NULL,
	barkPitch char(2)
	);
	
CREATE TABLE MESSAGES (
	id int REFERENCES PET_DATA,
	vet_cvr char(8) REFERENCES VETs,
	reason text NOT NULL	
);
---

-- VIEWS
CREATE VIEW CATS AS
    SELECT P.*, C.lifeCount FROM PET_DATA AS P JOIN CAT_DATA AS C ON P.id = C.id;

CREATE OR REPLACE VIEW DOGS AS
    SELECT P.*, D.barkPitch, 7*P.age AS dog_age
	FROM PET_DATA AS P 
		JOIN DOG_DATA AS D ON P.id = D.id;
	
CREATE OR REPLACE VIEW PETS AS
    SELECT P.*, C.lifeCount, D.barkPitch
	FROM PET_DATA AS P 
		LEFT OUTER JOIN CAT_DATA AS C ON P.id = C.id
		LEFT OUTER JOIN DOG_DATA AS D ON P.id = D.id;
---		
		
-- Procedures 
CREATE OR REPLACE PROCEDURE insert_dog (
	_name varchar(20), _age int, _bark char(2)
)
LANGUAGE SQL

AS $$
	WITH NEW_DOGS AS (
	    INSERT INTO PET_DATA (name, age) VALUES (_name,_age) RETURNING id
		)
	INSERT INTO DOG_DATA (id, barkPitch) SELECT id, _bark FROM NEW_DOGS;
$$;

CREATE OR REPLACE PROCEDURE insert_pet (
	_name varchar(20), 
	_age int, 
	_bark char(2) DEFAULT NULL, 
	_lifeCount int DEFAULT NULL,
	_vetcvr char(8) DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN

IF _bark IS NOT NULL AND _lifeCount IS NULL THEN 
	WITH NEW_DOGS AS (
	    INSERT INTO PET_DATA (name, age, vet_cvr) VALUES (_name,_age,_vetcvr) RETURNING id
		)
	INSERT INTO DOG_DATA (id, barkPitch) SELECT id, _bark FROM NEW_DOGS;

ELSIF _lifeCount IS NOT NULL AND _bark IS NULL THEN
	WITH NEW_CAT AS (
	    INSERT INTO PET_DATA (name, age, vet_cvr) VALUES (_name,_age,_vetcvr) RETURNING id
		)
	INSERT INTO CAT_DATA (id, lifeCount)  SELECT id, _lifeCount FROM NEW_CAT;
	
ELSE 
	INSERT INTO PET_DATA (name, age, vet_cvr) VALUES (_name,_age,_vetcvr);

END IF;
END $$;
---

-- FUNCTION
CREATE OR REPLACE FUNCTION avg_age_pet()
RETURNS real
AS $$

BEGIN 
	RETURN ROUND(AVG(age), 2) FROM PET_DATA;
END;
$$ LANGUAGE plpgsql; 
---

-- TRIGGER 
CREATE TRIGGER cat_life_change
  BEFORE UPDATE
  ON CAT_DATA
  FOR EACH ROW
  EXECUTE PROCEDURE cat_ded();


CREATE OR REPLACE FUNCTION cat_ded()
RETURNS TRIGGER 
  
AS $$
BEGIN
	IF NEW.lifeCount < OLD.lifeCount THEN
	INSERT INTO MESSAGES(id, vet_cvr, reason)
		 VALUES(OLD.id , (SELECT vet_cvr FROM PET_DATA WHERE PET_DATA.id = OLD.id), 'cat ded. lost 1 life');
	END IF;
	
	RETURN NEW;

END;
$$ LANGUAGE PLPGSQL;
---

-- INSERT
INSERT INTO VETs (vet_cvr, name) VALUES ('1', 'Carsten');
INSERT INTO VETs (vet_cvr, name) VALUES ('2', 'Lars');

Insert INTO Caretakers (name, phone) VALUES ('Anders', '120312');
Insert INTO Caretakers (name, phone) VALUES ('Martin', '88888888');
Insert INTO Caretakers (name, phone) VALUES ('Bent', '123');
Insert INTO Caretakers (name, phone) VALUES ('Benny', '345');
Insert INTO Caretakers (name, phone) VALUES ('Bo', '234554');
Insert INTO Caretakers (name, phone) VALUES ('Anders', '5433222');
Insert INTO Caretakers (name, phone) VALUES ('Jørn', '765');
Insert INTO Caretakers (name, phone) VALUES ('Lars Kasper', '212433');
Insert INTO Caretakers (name, phone) VALUES ('Hans Christian', '7464567');
Insert INTO Caretakers (name, phone) VALUES ('Kaj', '8765');

CALL insert_dog('Rasmus', 40, 'B1');
CALL insert_pet('felix', 9, null, 2, '1');
CALL insert_pet('CATT', 40, null, 5, '2');
CALL insert_pet('DOGGO', 40, 'Z9', null, '2');
CALL insert_pet('rufus', 4, null, 2, '1');
CALL insert_pet('claus', 60, 'x9', null, '1');
CALL insert_pet('alex', 40, 'Z9', null, '1');

CALL insert_pet('maggie', 40, null, 5, '2');
CALL insert_pet('roxy', 40, 'Z9', null, '2');
CALL insert_pet('sprocket', 4, null, 2, '1');
CALL insert_pet('lil hund', 60, 'x9', null, '1');
CALL insert_pet('skrr br', 40, 'Z9', null, '1');

CALL insert_pet('grrrrr', 40, null, 5, '2');
CALL insert_pet('bah! bah! bah!', 40, 'Z9', null, '2');
CALL insert_pet('dadadadada', 4, null, 2, '1');
CALL insert_pet('pepe', 60, 'x9', null, '1');
CALL insert_pet('niels christian', 40, 'Z9', null, '1');
CALL insert_pet('sniffer', 40, null, 5, '2');
CALL insert_pet('misser', 40, 'Z9', null, '2');
CALL insert_pet('pus', 4, null, 2, '1');
CALL insert_pet('Magnus', 60, 'x9', null, '1');


INSERT INTO pet_has_caretaker (caretaker_id, id) VALUES (1, 1);
INSERT INTO pet_has_caretaker (caretaker_id, id) VALUES (2, 2);
INSERT INTO pet_has_caretaker (caretaker_id, id) VALUES (2, 1);
INSERT INTO pet_has_caretaker (caretaker_id, id) VALUES (2, 3);
INSERT INTO pet_has_caretaker (caretaker_id, id) VALUES (2, 4);
INSERT INTO pet_has_caretaker (caretaker_id, id) VALUES (2, 6);
INSERT INTO pet_has_caretaker (caretaker_id, id) VALUES (2, 5);
INSERT INTO pet_has_caretaker (caretaker_id, id) VALUES (2, 7);
---

-- USER SETUP 
DROP OWNED BY bruger;
DROP ROLE bruger;
CREATE ROLE bruger WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	PASSWORD 'bruger';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO bruger;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO bruger;
---

