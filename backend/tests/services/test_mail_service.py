from unittest.mock import AsyncMock

import pytest

from src.services import MailService


class TestMailService:
    @pytest.fixture
    def fastmail(self) -> AsyncMock:
        return AsyncMock()

    @pytest.fixture
    def mail_service(self, fastmail: AsyncMock) -> MailService:
        return MailService(fastmail=fastmail)

    async def test_send_reset_mail_calls_fastmail(
        self,
        mail_service: MailService,
        fastmail: AsyncMock,
    ) -> None:
        await mail_service.send_reset_mail(email="test@test.com", reset_code="12345")
        fastmail.send_message.assert_called_once()

    async def test_send_reset_mail_passes_correct_email(
        self,
        mail_service: MailService,
        fastmail: AsyncMock,
    ) -> None:
        await mail_service.send_reset_mail(email="test@test.com", reset_code="12345")
        message = fastmail.send_message.call_args.kwargs["message"]
        assert "test@test.com" in message.recipients[0].email

    async def test_send_reset_mail_passes_correct_reset_code(
        self,
        mail_service: MailService,
        fastmail: AsyncMock,
    ) -> None:
        await mail_service.send_reset_mail(email="test@test.com", reset_code="12345")
        message = fastmail.send_message.call_args.kwargs["message"]
        assert message.template_body["code"] == "12345"

    async def test_send_reset_mail_uses_correct_template(
        self,
        mail_service: MailService,
        fastmail: AsyncMock,
    ) -> None:
        await mail_service.send_reset_mail(email="test@test.com", reset_code="12345")
        template_name = fastmail.send_message.call_args.kwargs["template_name"]
        assert template_name == "reset_password.html"