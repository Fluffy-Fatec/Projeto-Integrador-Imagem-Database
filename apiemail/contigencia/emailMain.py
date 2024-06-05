import subprocess
import os
import time
import psycopg2
from datetime import datetime
from sqlalchemy import create_engine, select, MetaData, Table
from sqlalchemy.orm import sessionmaker
import smtplib
import subprocess


class projectEmailMain:
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
            '-d', 'fluffyapicontigencia',
            '-c',
            f'{self.diretorioRaiz}\\backup\\backup_{dia}_{mes}_{ano}\\backup_{dia}_{mes}_{ano}.sql'
        ]

        ## Adicionando o diretório do PostgreSQL ao PATH ##
        pg_path = r'C:\Program Files\PostgreSQL\16\bin'
        self.env = os.environ.copy()
        self.env["PATH"] += os.pathsep + pg_path

    def run(self):
        try:
            self.pgrestore()
            time.sleep(5)
        except Exception as e:
            print(f"Erro: {e}")
            return

        try:
            listemail = self.listEmail()
            time.sleep(5)
        except Exception as e:
            print(f"Erro: {e}")
            return

        try:
            self.sendMail(listemail)
        except Exception as e:
            print(f"Erro: {e}")
            return

    def pgrestore(self):
        try:
            print("Executando o pg_restore:", ' '.join(self.pg_restore_cmd))
            subprocess.run(self.pg_restore_cmd, check=True, env={**self.env, 'PGPASSWORD': self.senha})
            print("pg_restore foi um sucesso!")
        except subprocess.CalledProcessError as e:
            print("Erro ao executar o pg_restore:", e)

    def listEmail(self):
        print('Buscando a lista de emails')

        ## Configuraçoes dos banco ##
        db_user = 'postgres'
        db_password = 'admin'
        db_host = 'localhost'
        db_port = '5432'
        db_name = 'fluffyapi'
        DATABASE_URL = f"postgresql+psycopg2://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"

        ## Criação do engine e da sessão ##
        engine = create_engine(DATABASE_URL)
        Session = sessionmaker(bind=engine)
        session = Session()
        metadata = MetaData()
        app_user = Table('app_user', metadata, autoload_with=engine)

        ## Seleção dos emails ##
        stmt = select(app_user.c.email)
        result = session.execute(stmt)

        ## Listar todos os emails ##
        emails = [row[0] for row in result]
        return emails

    def sendMail(self, receivers):
        print(receivers)
        sender = "Private Person <fluffyfatec@gmail.com>"
        receivers = [
            'Luizborges123@gmail.com', 'Analeal123@gmail.com'
        ]

        ## Configurações do servidor SMTP ##
        smtp_server = "sandbox.smtp.mailtrap.io"
        smtp_port = 2525
        smtp_user = "4b5b0c109a1ba0"
        smtp_password = "ca0133758b3278"

        try:
            with smtplib.SMTP(smtp_server, smtp_port) as server:
                server.starttls()  # Conexão segura
                server.login(smtp_user, smtp_password)  # Login no servidor

                for receiver in receivers:
                    message = f"""\
        Subject: Hi Mailtrap
        To: {receiver}
        From: {sender}

        Dear Users,

        I hope this message finds you well.

        We regret to inform you that our system has recently experienced a security incident. Our database was compromised by a hacker attack, and we are diligently working to understand the full scope of the breach.

        We want to assure you that we are taking all necessary steps to mitigate this incident and ensure the safety of your data. Upon identifying the breach, we immediately:

        Isolated the affected systems to prevent further damage.
        Hired cybersecurity experts to conduct a thorough investigation.
        Are collaborating with the appropriate authorities to investigate the origin of the attack.
        We are conducting a meticulous analysis to determine which data may have been accessed. At this time, we recommend the following preventive actions for all our users:

        Change your passwords immediately. If you use the same password on other services, we suggest changing it there as well.
        Be vigilant for any suspicious activity in your accounts and financial statements.
        Do not share personal information through unsolicited emails or messages.
        We understand the seriousness of this situation and the concern it may cause. The privacy and security of our users are of utmost importance to us, and we are committed to addressing this issue with the highest transparency and efficiency.

        We will keep everyone informed about the progress of the investigation and any further actions that may be necessary. We appreciate your patience and understanding as we work to resolve this matter.

        If you have any questions or need additional assistance, please contact our support team at fluffyfatec0@gmail.com.

        Sincerely,

        Fluffy"""

                    server.sendmail(sender, receiver, message)
                    print(f"Email enviado para {receiver}")

        except Exception as e:
            print(f"Falha ao enviar e-mail: {e}")

 




