DROP TABLE IF EXISTS user;
CREATE TABLE user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255),
    password VARCHAR(255),
	role VARCHAR(255),
    nome VARCHAR(255),
    email VARCHAR(255),
    celular VARCHAR(255),
    cpf VARCHAR(255),
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS invite;
CREATE TABLE invite (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255),
    solicitante VARCHAR(255),
    tokenInvite VARCHAR(255),
    typeUser VARCHAR(255),
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (solicitante) REFERENCES user(username)
);

DROP TABLE IF EXISTS review;
CREATE TABLE review (
    id SERIAL PRIMARY KEY,
    review TEXT,
    comentario TEXT,
    sentimento VARCHAR(255),
    titulo VARCHAR(255),
    estado VARCHAR(255),
    cidade VARCHAR(255),
    rua VARCHAR(255),
    lat NUMERIC,
    long NUMERIC,
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);