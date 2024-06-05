import subprocess
import os
import pymongo
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import time
from datetime import datetime
import psycopg2
class projectDeleteMain:
    def __init__(self):

        data_atual = datetime.now()
        dia = str(data_atual.day).zfill(2)
        mes = str(data_atual.month).zfill(2)
        ano = data_atual.year

        ## Configuração do restore ##
        self.senha = "admin"
        self.diretorioRaiz = os.getcwd()
        self.pg_restore_cmd = [
            'pg_restore',
            '-h', '127.0.0.1',
            '-p', '5432',
            '-U', 'postgres',
            '-d', 'fluffyapi',
            '-c',
            f'{self.diretorioRaiz}\\backup\\backup_{dia}_{mes}_{ano}\\backup_{dia}_{mes}_{ano}.sql'
        ]

        ## Adicionando o diretório do PostgreSQL ao PATH ##
        pg_path = r'C:\Program Files\PostgreSQL\16\bin'
        self.env = os.environ.copy()
        self.env["PATH"] += os.pathsep + pg_path

        ## Conectando ao MongoDB ##
        client = pymongo.MongoClient("mongodb://localhost:27017/")
        db = client['fluffyapi']
        self.collection = db['blackList']

        ## Dados de conexão com o banco de dados PostgreSQL ##
        db_user = 'postgres'
        db_password = 'admin'
        db_host = 'localhost'
        db_port = '5432'
        db_name = 'fluffyapi'
        self.engine = create_engine(f'postgresql+psycopg2://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}')

    def run(self):
        try:
            self.pgrestore()
            time.sleep(5)
        except Exception as e:
            print(f"Erro: {e}")
            return

        try:
            df = self.mongodb()
            time.sleep(5)
        except Exception as e:
            print(f"Erro: {e}")
            return

        try:
            self.postgre(df)
        except Exception as e:
            print(f"Erro: {e}")
            return



    def mongodb(self):

        print('Buscando dados da blacklist')
        cursor = self.collection.find()
        df = pd.DataFrame(list(cursor))
        if '_id' in df.columns:
            df.drop(columns=['_id', '_class'], inplace=True)
        return df

    def postgre(self, df):

        ids_apagar = tuple(df['idBlacklist'].tolist())
        delete_query = f"DELETE FROM app_user WHERE id IN {ids_apagar}"
        print(f"Query de deleção: {delete_query}")

        # Cria uma sessão para gerenciar a transação
        Session = sessionmaker(bind=self.engine)
        session = Session()

        try:
            result = session.execute(text(delete_query))
            session.commit()
            print(f'{result.rowcount} registros apagados.')
            # #Verifique os dados restantes na tabela para depuração
            # remaining_users = session.execute(text("SELECT * FROM app_user")).fetchall()
            # print(f"Registros restantes: {remaining_users}")
        except Exception as e:
            session.rollback()
            print(f"Erro durante a deleção: {e}")
        finally:
            session.close()
        self.engine.dispose()

    def pgrestore(self):
        try:
            print("Executando pg_restore:", ' '.join(self.pg_restore_cmd))
            subprocess.run(self.pg_restore_cmd, check=True, env={**self.env, 'PGPASSWORD': self.senha})
            print("pg_restore foi um sucesso!")
        except subprocess.CalledProcessError as e:
            print("Erro ao executar o pg_restore:", e)
