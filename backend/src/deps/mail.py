from fastapi import Depends
from fastapi_mail import FastMail

from src.core import get_mail
from src.services import MailService


def get_mail_service(fastmail: FastMail = Depends(get_mail)) -> MailService:
    return MailService(fastmail)