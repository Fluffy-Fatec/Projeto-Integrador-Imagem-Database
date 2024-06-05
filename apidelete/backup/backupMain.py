import os
import subprocess
import schedule
import time
from datetime import datetime

class projectBackupMain:
    def __init__(self):
        self.diretorioRaiz = os.getcwd()
        self.senha = "admin"
    def run(self):

        ## Configurando diretorio ##
        now = datetime.now()
        backup_filename = now.strftime("backup_%d_%m_%Y.sql")
        backup_pathname = now.strftime("backup_%d_%m_%Y")
        backup_path = os.path.join("backup", backup_pathname, backup_filename)
        dir = os.path.join("backup", backup_pathname)
        os.makedirs(dir, exist_ok=True)

        ## Configurando dump ##
        pg_dump_cmd = [
            'pg_dump',
            '-h', '127.0.0.1',
            '-p', '5432',
            '-U', 'postgres',
            '-d', 'fluffyapi',
            '-F', 'c',
            '-f', backup_path
        ]

        ## Adicionando o diretório do PostgreSQL ao PATH ##
        pg_path = r'C:\Program Files\PostgreSQL\16\bin'
        env = os.environ.copy()
        env["PATH"] += os.pathsep + pg_path

        print(f"Executando backup: {backup_filename}")

        ## Executa o comando pg_dump ##
        try:
            subprocess.run(pg_dump_cmd, check=True, env={**env, 'PGPASSWORD': self.senha})
            print("pg_dump concluído com sucesso!")
        except subprocess.CalledProcessError as e:
            print("Erro ao executar pg_dump:", e)