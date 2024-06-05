import os
import subprocess
import os
import schedule
import time
from datetime import datetime

class projectBackupMain:
    def __init__(self):
        self.diretorioRaiz = os.getcwd()

        # Definindo a senha do banco de dados
        self.senha = "admin"
    def run(self):

        # Gerando o nome do arquivo de backup com a data atual
        now = datetime.now()
        backup_filename = now.strftime("backup_%d_%m_%Y.sql")
        backup_pathname = now.strftime("backup_%d_%m_%Y")
        backup_path = os.path.join("backup", backup_pathname, backup_filename)
        dir = os.path.join("backup", backup_pathname)
        os.mkdir(dir)

        pg_dump_cmd = [
            'pg_dump',
            '-h', '127.0.0.1',
            '-p', '5432',
            '-U', 'postgres',
            '-d', 'fluffyapi',
            '-F', 'c',
            '-f', backup_path
        ]

        # Adicionando o diretório do PostgreSQL ao PATH
        pg_path = r'C:\Program Files\PostgreSQL\16\bin'
        env = os.environ.copy()
        env["PATH"] += os.pathsep + pg_path

        print(f"Executando backup: {backup_filename}")

        # Executa o comando pg_dump
        try:
            subprocess.run(pg_dump_cmd, check=True, env={**env, 'PGPASSWORD': self.senha})
            print("pg_dump concluído com sucesso!")
        except subprocess.CalledProcessError as e:
            print("Erro ao executar pg_dump:", e)

        # # Agendar o backup para ser executado uma vez por dia
        # schedule.every().day.at("02:00").do(backup_db)

        # # Loop principal para manter o script rodando
        # while True:
        #     schedule.run_pending()
        #     time.sleep(60)