from pydantic import BaseModel
from typing import Optional

class EventData(BaseModel):
    title: Optional[str] = None
    description : Optional[str] = None
    location : Optional[str] = None
    eventDate : Optional[str] = None
    agenda : Optional[str] = None