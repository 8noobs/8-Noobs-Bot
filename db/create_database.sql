CREATE SCHEMA BotData;
USE BotData;
CREATE TABLE Usuario (
id INT(50) PRIMARY KEY,
alias VARCHAR(40),
nombre VARCHAR(100)
);

CREATE TABLE Mensaje (
id INT(50) PRIMARY KEY,	
texto LONGTEXT, 
fecha DATETIME,
audio BOOLEAN,
documento BOOLEAN,
video BOOLEAN,
foto BOOLEAN,
id_user INT(50) ,
CONSTRAINT fk FOREIGN KEY (id_user) REFERENCES Usuario(id));