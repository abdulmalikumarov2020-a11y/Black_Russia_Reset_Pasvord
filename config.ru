import os
from dotenv import load_dotenv

load_dotenv()

BOT_TOKEN = os.getenv("BOT_TOKEN", "8890429451:AAGv9ieglHjfIGjwIImCcz2YNVaqDZMCmDE")
ADMIN_ID = int(os.getenv("ADMIN_ID", 1491315056))
CHANNEL_ID = os.getenv("CHANNEL_ID", "@mooby_channel")
