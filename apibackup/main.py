import schedule
import time
from backup import backupMain

def job():
    obj_project = backupMain.projectBackupMain()
    obj_project.run()

if __name__ == "__main__":
    schedule.every(1).minutes.do(job)

    while True:
        schedule.run_pending()
        time.sleep(1)
