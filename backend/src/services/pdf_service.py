from pathlib import Path

from src.core import config
from src.core.errors import ResourceNotFoundError


class PdfService:
    def __init__(self):
        self.docs_path = Path(config.pdf.get_pdf_path)

    def get_agreement_path(self) -> Path:
        file_path = self.docs_path / config.pdf.agreement_name

        if not file_path.exists():
            raise ResourceNotFoundError

        return file_path
