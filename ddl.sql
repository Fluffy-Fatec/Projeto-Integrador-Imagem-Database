DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS invite;
DROP TABLE IF EXISTS app_user;

CREATE TABLE app_user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE,
    password VARCHAR(255),
    role VARCHAR(255),
    nome VARCHAR(255),
    email VARCHAR(255),
    celular VARCHAR(255),
    cpf VARCHAR(255),
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE invite (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255),
    solicitante SERIAL,
    tokenInvite VARCHAR(255),
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_solicitante FOREIGN KEY (solicitante) REFERENCES app_user(id)
);

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
