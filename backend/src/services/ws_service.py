from sqlalchemy.ext.asyncio import AsyncSession


class WSService:
    def __init__(self, session: AsyncSession):
        self.session = session