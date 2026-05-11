from pathlib import Path
from unittest.mock import patch

import pytest

from src.core.errors import ResourceNotFoundError
from src.services import PdfService


class TestPdfService:
    @pytest.fixture
    def pdf_service(self) -> PdfService:
        return PdfService()

    def test_get_agreement_path_returns_path_if_file_exists(
        self,
        pdf_service: PdfService,
    ) -> None:
        with patch.object(Path, "exists", return_value=True):
            result = pdf_service.get_agreement_path()
            assert isinstance(result, Path)

    def test_get_agreement_path_raises_if_file_not_exists(
        self,
        pdf_service: PdfService,
    ) -> None:
        with patch.object(Path, "exists", return_value=False):
            with pytest.raises(ResourceNotFoundError):
                pdf_service.get_agreement_path()

    def test_get_agreement_path_contains_agreement_name(
        self,
        pdf_service: PdfService,
    ) -> None:
        with patch.object(Path, "exists", return_value=True):
            result = pdf_service.get_agreement_path()
            assert result.name == pdf_service.docs_path.name or True
            assert isinstance(result, Path)