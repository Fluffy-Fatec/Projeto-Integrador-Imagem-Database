DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS invite;
DROP TABLE IF EXISTS alteracao_campo;
DROP TABLE IF EXISTS status_termo;
DROP TABLE IF EXISTS termo;
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
    solicitante INTEGER,
    tokenInvite VARCHAR(255),
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_invite_solicitante FOREIGN KEY (solicitante) REFERENCES app_user(id) ON DELETE CASCADE
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

CREATE TABLE alteracao_campo (
    id SERIAL PRIMARY KEY,
    idUser INTEGER,
    idAdmin INTEGER,
    novoUsername VARCHAR(255),
    novoPassword VARCHAR(255),
    novoNome VARCHAR(255),
    novoEmail VARCHAR(255),
    novoCelular VARCHAR(255),
    novoCpf VARCHAR(255),
    status VARCHAR(20), 
    dataAprovacao TIMESTAMP, 
    dataRejeicao TIMESTAMP, 
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE termo (
    id SERIAL PRIMARY KEY,
    termo TEXT,
    versao VARCHAR(255),
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE status_termo (
    id SERIAL PRIMARY KEY,
    idTermo INTEGER,
    idUser INTEGER,
    status VARCHAR(20), 
    dataAprovacao TIMESTAMP,
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_status_termo_user_id FOREIGN KEY (idUser) REFERENCES app_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_status_termo_termo_id FOREIGN KEY (idTermo) REFERENCES termo(id) ON DELETE CASCADE
);




