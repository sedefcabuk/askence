from typing import Dict, List
from pydantic import BaseModel

class ChatBody(BaseModel):
    history: List[Dict[str, str]]
    query:str