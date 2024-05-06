
-- SELECT DE TODAS AS TABELAS
SELECT * FROM review;
SELECT * FROM invite;
SELECT * FROM alteracao_campo;
SELECT * FROM status_termo;
SELECT * FROM termo;
SELECT * FROM app_user;
SELECT * FROM  palavra;
SELECT * FROM  notificacao;
SELECT * FROM  notificacao_termo;
----------------------------------------------------------------------------------------

-- VERIFICAR TODAS AS FUNCTIONS / TRIGGER SE ESTÃO CRIADAS
SELECT trigger_name,
       event_object_table,
       action_statement,
       action_timing
FROM information_schema.triggers;

SELECT routine_name,
       data_type,
       routine_definition
FROM information_schema.routines
WHERE specific_schema NOT IN ('pg_catalog', 'information_schema');
----------------------------------------------------------------------------------------

-- DROP DAS TABELAS
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS invite;
DROP TABLE IF EXISTS alteracao_campo;
DROP TABLE IF EXISTS status_termo;
DROP TABLE IF EXISTS termo;
DROP TABLE IF EXISTS app_user;
DROP TABLE IF EXISTS palavra;
DROP TABLE IF EXISTS notificacao;
DROP TABLE IF EXISTS notificacao_termo;
----------------------------------------------------------------------------------------

--CRIAÇÃO DAS TABELAS
CREATE TABLE app_user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE,
    password VARCHAR(255),
    role VARCHAR(255),
    nome VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    celular VARCHAR(255) UNIQUE,
    cpf VARCHAR(255) UNIQUE,
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE invite (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    solicitante INTEGER,
    tokenInvite VARCHAR(255),
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_invite_solicitante FOREIGN KEY (solicitante) REFERENCES app_user(id)
);

CREATE TABLE alteracao_campo (
    id SERIAL PRIMARY KEY,
    idUser INTEGER,
    idAdmin INTEGER,
    novoUsername VARCHAR(255),
    novoNome VARCHAR(255),
    novoEmail VARCHAR(255),
    novoCelular VARCHAR(255),
    novoCpf VARCHAR(255),
    status VARCHAR(20) CHECK (status IN ('aprovado', 'pendente', 'rejeitado', 'Aprovado', 'Pendente', 'Rejeitado')), 
    dataAprovacao TIMESTAMP, 
    dataRejeicao TIMESTAMP, 
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_alteracao_campo_idUser FOREIGN KEY (idUser) REFERENCES app_user(id),
    CONSTRAINT fk_alteracao_campo_idAdmin FOREIGN KEY (idAdmin) REFERENCES app_user(id)
);

CREATE TABLE termo (
    id SERIAL PRIMARY KEY,
    termo TEXT,
    versao VARCHAR(255),
	atual_versao BOOLEAN,
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE termo_funcao (
    id SERIAL PRIMARY KEY,
    func_name VARCHAR(255),
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE status_termo (
    id SERIAL PRIMARY KEY,
    idTermo INTEGER,
	idTermoFunc INTEGER,
    idUser INTEGER,
    status VARCHAR(20), 
    dataAprovacao TIMESTAMP,
    creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_status_termo_user_id FOREIGN KEY (idUser) REFERENCES app_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_status_termo_termo_id FOREIGN KEY (idTermo) REFERENCES termo(id) ON DELETE CASCADE,
    CONSTRAINT fk_status_termo_termofunc_id FOREIGN KEY (idTermoFunc) REFERENCES termo_funcao(id) ON DELETE CASCADE
);

CREATE TABLE review (
    review_id VARCHAR(255) PRIMARY KEY,
	review_comment_message TEXT,
	review_score VARCHAR(255),
	predictions VARCHAR(255),
	geolocation_lat VARCHAR(255),
	geolocation_lng VARCHAR(255),
	geolocation_state VARCHAR(255),
	geolocation_country VARCHAR(255),
	review_creation_date TIMESTAMP,
	origin VARCHAR(255),
	geolocation_point VARCHAR(255),
	creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE palavra (
    id SERIAL PRIMARY KEY,
	word VARCHAR(255),
	counts VARCHAR(255),
	sentiment VARCHAR(255)
);

CREATE TABLE notificacao (
    id SERIAL PRIMARY KEY,
	id_alteracao_campo INTEGER,
	idUser INTEGER,
    idAdmin INTEGER,
	tipo_notificacao VARCHAR(255),
	mensagem TEXT,
	flag_notificacao VARCHAR(255),
	creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT fk_notificacao_alteracao_campor FOREIGN KEY (id_alteracao_campo) REFERENCES alteracao_campo(id),
	CONSTRAINT fk_notificacao_idUser FOREIGN KEY (idUser) REFERENCES app_user(id),
    CONSTRAINT fk_notificacao_idAdmin FOREIGN KEY (idAdmin) REFERENCES app_user(id)
);

CREATE TABLE notificacao_termo (
    id SERIAL PRIMARY KEY,
	idUser INTEGER,
	idTermo INTEGER,
	mensagem TEXT,
	flag_notificacao VARCHAR(255),
	creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT fk_notificacao_app_user FOREIGN KEY (idUser) REFERENCES app_user(id),
	CONSTRAINT fk_notificacao_termo FOREIGN KEY (idTermo) REFERENCES termo(id)
);
--flag_notificacao 1 sim / 0 não
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--FUNCTION E TRIGGERS - NOTIFICAÇÃO

DROP FUNCTION IF EXISTS function_notificacao_admin();
CREATE OR REPLACE FUNCTION function_notificacao_admin()
RETURNS TRIGGER AS $$
DECLARE
    formatted_date TEXT;
BEGIN
    formatted_date := TO_CHAR(CURRENT_TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS');
    INSERT INTO notificacao (id_alteracao_campo, idUser, tipo_notificacao, mensagem, flag_notificacao)
    VALUES (NEW.id, NEW.idUser, 'Admin ', 'Usuario ' || (SELECT nome FROM app_user WHERE id = NEW.idUser) || ' requested a change of data in ' || formatted_date, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notificacao_admin ON alteracao_campo;
CREATE TRIGGER trigger_notificacao_admin
AFTER INSERT ON alteracao_campo
FOR EACH ROW
EXECUTE FUNCTION function_notificacao_admin();

DROP FUNCTION IF EXISTS function_notificacao_usuario();
CREATE OR REPLACE FUNCTION function_notificacao_usuario()
RETURNS TRIGGER AS $$
DECLARE
    formatted_date TEXT;
BEGIN
	formatted_date := TO_CHAR(CURRENT_TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS');
    INSERT INTO notificacao (id_alteracao_campo, idUser, idAdmin, tipo_notificacao, mensagem, flag_notificacao)
    VALUES (OLD.id, OLD.idUser, NEW.idAdmin, 'Usuario', 
        CASE 
            WHEN NEW.status = 'aprovado' THEN 'Update completed successfully' || formatted_date 
            WHEN NEW.status = 'rejeitado' THEN 'Update rejected, please check the data and try again at' || formatted_date 
            ELSE 'ERROR'
        END, 
        '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notificacao_usuario ON alteracao_campo;
CREATE TRIGGER trigger_notificacao_usuario
BEFORE UPDATE OF idadmin ON alteracao_campo
FOR EACH ROW
EXECUTE FUNCTION function_notificacao_usuario();

-- TESTE DA TRIGGER
-- select * from notificacao order by 1 asc;
-- select * from alteracao_campo order by 1 asc;
-- delete from notificacao where id in (2, 1)
-- delete from notificacao
-- delete from alteracao_campo
-- select * from app_user order by 1 asc;

-- INSERT INTO alteracao_campo (idUser, novoUsername, novoNome, novoEmail, novoCelular, novoCpf, status)
-- VALUES (11, 'aldrikalvaro', 'alvaro', 'Aldrikalvaro1234@gmail.com', '(54) 91887-7654', '321.234.901-21', 'pendente');

-- UPDATE alteracao_campo
-- SET idadmin = 1, dataaprovacao = current_timestamp, status = 'Aprovado'
-- WHERE id = 24;

-- UPDATE alteracao_campo
-- SET idadmin = 1, datarejeicao = current_timestamp, status = 'Rejeitado'
-- WHERE id = 23;

-------------------------------------------------------------------------------

--FUNCTION E TRIGGERS - NOTIFICAÇÃO NOVA VERSAO DO TERMO DISPONIVEL

CREATE OR REPLACE FUNCTION function_notificacao_termo()
RETURNS TRIGGER AS $$
DECLARE
    user_id INTEGER;
BEGIN
    FOR user_id IN SELECT id FROM app_user
    LOOP
        INSERT INTO notificacao_termo (idUser, idTermo, mensagem, flag_notificacao)
        VALUES (user_id, NEW.id, 'New acceptance term available', '0');
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS trigger_notificacao_termo ON termo;
CREATE TRIGGER trigger_notificacao_termo
AFTER INSERT ON termo
FOR EACH ROW
EXECUTE FUNCTION function_notificacao_termo();



-------------------------------------------------------------------------------

--FUNCTIONS EM PRODUÇÃO - MAIUSCULA

DROP FUNCTION IF EXISTS function_primeira_maiuscula(text);

CREATE OR REPLACE FUNCTION function_primeira_maiuscula(text) RETURNS text AS $$
BEGIN
    RETURN INITCAP(SUBSTRING($1 FROM 1 FOR 1)) || LOWER(SUBSTRING($1 FROM 2));
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS function_insert_app_user_maiuscula();
CREATE OR REPLACE FUNCTION function_insert_app_user_maiuscula() RETURNS TRIGGER AS $$
BEGIN
    NEW.email := function_primeira_maiuscula(NEW.email);
    NEW.nome := function_primeira_maiuscula(NEW.nome);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS function_insert_invite_maiuscula();
CREATE OR REPLACE FUNCTION function_insert_invite_maiuscula() RETURNS TRIGGER AS $$
BEGIN
    NEW.email := function_primeira_maiuscula(NEW.email);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS function_insert_alteracao_campo_maiuscula();
CREATE OR REPLACE FUNCTION function_insert_alteracao_campo_maiuscula() RETURNS TRIGGER AS $$
BEGIN
    NEW.status := function_primeira_maiuscula(NEW.status);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS function_update_status_maiuscula();
CREATE OR REPLACE FUNCTION function_update_status_maiuscula()
RETURNS TRIGGER AS $$
BEGIN
    NEW.status := function_primeira_maiuscula(NEW.status);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS function_update_nome_maiuscula();
CREATE OR REPLACE FUNCTION function_update_nome_maiuscula()
RETURNS TRIGGER AS $$
BEGIN
    NEW.nome := function_primeira_maiuscula(NEW.nome);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS function_update_email_maiuscula();
CREATE OR REPLACE FUNCTION function_update_email_maiuscula()
RETURNS TRIGGER AS $$
BEGIN
    NEW.email := function_primeira_maiuscula(NEW.email);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_insert_app_user_maiuscula ON app_user;
CREATE TRIGGER trigger_insert_app_user_maiuscula
BEFORE INSERT ON app_user
FOR EACH ROW
EXECUTE FUNCTION function_insert_app_user_maiuscula();

DROP TRIGGER IF EXISTS trigger_insert_invite_maiuscula ON invite;
CREATE TRIGGER trigger_insert_invite_maiuscula
BEFORE INSERT ON invite
FOR EACH ROW
EXECUTE FUNCTION function_insert_invite_maiuscula();

DROP TRIGGER IF EXISTS trigger_insert_alteracao_campo_maiuscula ON alteracao_campo;
CREATE TRIGGER trigger_insert_alteracao_campo_maiuscula
BEFORE INSERT ON alteracao_campo
FOR EACH ROW
EXECUTE FUNCTION function_insert_alteracao_campo_maiuscula();

DROP TRIGGER IF EXISTS trigger_update_alteracao_campo_maiuscula ON alteracao_campo;
CREATE TRIGGER trigger_update_alteracao_campo_maiuscula
BEFORE UPDATE OF status ON alteracao_campo
FOR EACH ROW
EXECUTE FUNCTION function_update_status_maiuscula();

DROP TRIGGER IF EXISTS trigger_update_app_user_nome ON app_user;
CREATE TRIGGER trigger_update_app_user_nome
BEFORE UPDATE OF nome ON app_user
FOR EACH ROW
EXECUTE FUNCTION function_update_nome_maiuscula();

DROP TRIGGER IF EXISTS trigger_update_app_user_email ON app_user;
CREATE TRIGGER trigger_update_app_user_email
BEFORE UPDATE OF email ON app_user
FOR EACH ROW
EXECUTE FUNCTION function_update_email_maiuscula();

---------------------------------------------------------------------------------------------------------------------------------

-- PARA SETAR O CAMPO WORD COMO PRIMEIRA MAISCULA
UPDATE palavra
SET word = INITCAP(word);
---------------------------------------------------------------------------------------------------------------------------------

-- Criação de um índice para a coluna review_score
CREATE INDEX idx_review_score ON review (review_score);

-- Criação de um índice para a coluna predictions
CREATE INDEX idx_predictions ON review (predictions);

-- Criação de um índice para a coluna geolocation_lat
CREATE INDEX idx_geolocation_lat ON review (geolocation_lat);

-- Criação de um índice para a coluna geolocation_lng
CREATE INDEX idx_geolocation_lng ON review (geolocation_lng);

-- Criação de um índice para a coluna geolocation_state
CREATE INDEX idx_geolocation_state ON review (geolocation_state);

-- Criação de um índice para a coluna geolocation_country
CREATE INDEX idx_geolocation_country ON review (geolocation_country);

-- Criação de um índice para a coluna review_creation_date
CREATE INDEX idx_review_creation_date ON review (review_creation_date);

-- Criação de um índice para a coluna origin
CREATE INDEX idx_origin ON review (origin);



-- Inserir novos registros com a coluna mensagem em inglês
INSERT INTO notificacao (id, id_alteracao_campo, iduser, idadmin, tipo_notificacao, mensagem, flag_notificacao)
VALUES
(5, 21, 8, NULL, 'Admin', 'User Emanuele Campos requested a data change on 24/04/2024 14:22:03', '0'),
(6, 22, 3, NULL, 'Admin', 'User User requested a data change on 24/04/2024 14:22:10', '0'),
(7, 23, 5, NULL, 'Admin', 'User Luiz Borges requested a data change on 24/04/2024 14:22:16', '0'),
(8, 21, 8, 1, 'User', 'Update completed successfully - 24/04/2024 14:22:37', '0'),
(9, 22, 3, 1, 'User', 'Update rejected, please check the data and try again - 24/04/2024 14:22:41', '0'),
(10, 23, 5, 1, 'User', 'Update rejected, please check the data and try again - 24/04/2024 14:55:34', '0'),
(11, 24, 10, NULL, 'Admin', 'User Victor Fernandes requested a data change on 24/04/2024 15:23:09', '0'),
(12, 24, 10, 1, 'User', 'Update completed successfully on 24/04/2024 15:23:29', '0'),
(13, 25, 11, NULL, 'Admin', 'User Tiago Camilo requested a data change on 24/04/2024 15:41:49', '0');


-- SELECT * FROM status_termo;
-- SELECT * FROM termo;
-- SELECT * FROM app_user order by 1 asc;


-- TESTE DO TERMO
--SELECT * FROM NOTIFICACAO_TERMO order by 2, 3 asc;
--
--delete from notificacao_termo
--SELECT * FROM termo order by 1 asc
--SELECT * FROM status_termo order by 1 asc
--SELECT * FROM notificacao_termo;
--
--
--INSERT INTO termo (termo, versao, atual_versao) VALUES 
--('TERMO 1', '4', true);
-- ('Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', '2', FALSE),
-- ('Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.', '3', TRUE);


--select * from status_termo order by 2 asc;

-- -- Inserções de teste para a tabela 'status_termo'
-- INSERT INTO status_termo (idTermo, idUser, dataAprovacao) VALUES 
-- (2, 5, '2024-04-23 14:30:00'),
-- (2, 4, '2024-03-21 09:45:00'),
-- (3, 4, '2024-04-22 09:45:00'),
-- (1, 1, '2024-02-10 14:30:00'),
-- (2, 1, '2024-03-20 09:45:00'),
-- (3, 1, '2024-04-24 11:20:00');

--NSERT INTO status_termo (idTermo, idUser, dataAprovacao) VALUES 
--3, 1, '2024-04-29 20:00:00'),
--3, 3, '2024-04-29 20:00:00'),
--3, 4, '2024-04-29 20:00:00'),
--3, 5, '2024-04-29 20:00:00'),
--3, 6, '2024-04-29 20:00:00'),
--3, 8, '2024-04-29 20:00:00'),
--3, 9, '2024-04-29 20:00:00'),
--3, 10, '2024-04-29 20:00:00'),
--3, 11, '2024-04-29 20:00:00'),
--3, 12, '2024-04-29 20:00:00'),
--3, 13, '2024-04-29 20:00:00'),
--3, 15, '2024-04-29 20:00:00'),
--3, 17, '2024-04-29 20:00:00'),
--3, 18, '2024-04-29 20:00:00'),
--3, 19, '2024-04-29 20:00:00');


-- TRATAMENTO REVIEW 
--ALTER TABLE review
--ADD COLUMN geolocation_point VARCHAR(255),
--ADD COLUMN geolocation_geography VARCHAR(255);


-- ALTER TABLE review
-- ALTER COLUMN geolocation_geography TYPE geography(Point, 4326) USING ST_SetSRID(ST_MakePoint(geolocation_lng::double precision, geolocation_lat::double precision), 4326);

-- ALTER TABLE review
-- ALTER COLUMN geolocation_point TYPE POINT USING POINT(geolocation_lat_num, geolocation_lng_num);

--ALTER TABLE review
--DROP COLUMN geolocation_lat_num,
--DROP COLUMN geolocation_lng_num;