import subprocess
import os
import pymongo
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import time
import psycopg2
from datetime import datetime
class projectDeleteMain:
    def __init__(self):



        # Obter a data atual
        data_atual = datetime.now()

        # Extrair o dia, mês e ano
        dia = str(data_atual.day).zfill(2)
        mes = str(data_atual.month).zfill(2)
        ano = data_atual.year

        # PG_DUMP #
        self.senha = "admin"

        self.diretorioRaiz = os.getcwd()
        print(self.diretorioRaiz)
        print(f"{self.diretorioRaiz}\\backup\\backup_{dia}_{mes}_{ano}\\backup_{dia}_{mes}_{ano}.sql")

        # Construct the pg_restore command
        self.pg_restore_cmd = [
            'pg_restore',
            '-h', '127.0.0.1',
            '-p', '5432',
            '-U', 'postgres',
            '-d', 'fluffyapi',
            '-c',  # Clean (drop) the database objects before recreating them
            f'{self.diretorioRaiz}\\backup\\backup_{dia}_{mes}_{ano}\\backup_{dia}_{mes}_{ano}.sql'
        ]



        # Adicionando o diretório do PostgreSQL ao PATH
        pg_path = r'C:\Program Files\PostgreSQL\16\bin'
        self.env = os.environ.copy()
        self.env["PATH"] += os.pathsep + pg_path


        # MONGODB #
        # Conectando ao MongoDB
        client = pymongo.MongoClient("mongodb://localhost:27017/")

        # Selecionando o banco de dados
        db = client['fluffyapi']

        # Selecionando a coleção
        self.collection = db['blackList']

        # POSTGRES #
        # Dados de conexão com o banco de dados PostgreSQL
        db_user = 'postgres'
        db_password = 'admin'
        db_host = 'localhost'
        db_port = '5432'
        db_name = 'fluffyapi'
        # Cria a conexão com o banco de dados
        self.engine = create_engine(f'postgresql+psycopg2://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}')


    def run(self):

        self.pgrestore()
        time.sleep(5)
        df = self.mongodb()
        time.sleep(5)
        self.postgre(df)

    def mongodb(self):
        # Buscando os dados na coleção
        cursor = self.collection.find()

        # Convertendo os dados para um DataFrame do Pandas
        df = pd.DataFrame(list(cursor))

        if '_id' in df.columns:
            df.drop(columns=['_id', '_class'], inplace=True)

        # Exibindo o DataFrame
        print(df)
        return df

    def postgre(self, df):
        # Converte os IDs do DataFrame em uma tupla para usar na cláusula SQL IN
        ids_para_apagar = tuple(df['idBlacklist'].tolist())

        # Constrói a query de deleção
        delete_query = f"DELETE FROM app_user WHERE id IN {ids_para_apagar}"

        # Verifique se a consulta SQL está correta
        print(f"Query de deleção: {delete_query}")

        # Cria uma sessão para gerenciar a transação
        Session = sessionmaker(bind=self.engine)
        session = Session()

        try:
            # Executa a query de deleção
            result = session.execute(text(delete_query))
            session.commit()
            print(f'{result.rowcount} registros apagados.')

            # Verifique os dados restantes na tabela para depuração
            remaining_users = session.execute(text("SELECT * FROM app_user")).fetchall()
            print(f"Registros restantes: {remaining_users}")
        except Exception as e:
            session.rollback()
            print(f"Erro durante a deleção: {e}")
        finally:
            session.close()

        # Fechar a conexão
        self.engine.dispose()

    def pgrestore(self):
        # Execute pg_restore
        try:
            print("Executing pg_restore command:", ' '.join(self.pg_restore_cmd))
            subprocess.run(self.pg_restore_cmd, check=True, env={**self.env, 'PGPASSWORD': self.senha})
            print("pg_restore completed successfully!")
        except subprocess.CalledProcessError as e:
            print("Error executing pg_restore:", e)
