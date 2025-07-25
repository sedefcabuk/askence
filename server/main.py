import asyncio
import os
from fastapi import FastAPI, WebSocket
import uvicorn

from pydantic_models.chat_body import ChatBody
from services.llm_service import LLMService
from services.sort_source_service import SortSourceService
from services.search_service import SearchService


app = FastAPI()

search_service = SearchService()
sort_source_service = SortSourceService()
llm_service = LLMService()


# chat websocket
@app.websocket("/ws/chat")
async def websocket_chat_endpoint(websocket: WebSocket):
    await websocket.accept()

    conversation_history = []

    try:
        while True:
            data = await websocket.receive_json()
            query = data.get("query")
            if query is None:
                continue  # Boş veri geldiyse atla

            # 📌 Geçmişe kullanıcı mesajını ekle
            conversation_history.append({"role": "user", "content": query})

            search_results = search_service.web_search(query)
            sorted_results = sort_source_service.sort_sources(query, search_results)
            await websocket.send_json({"type": "search_result", "data": sorted_results})
            response_chunks = llm_service.generate_response(conversation_history, sorted_results)
            full_response = ""
            for chunk in response_chunks:
                full_response += chunk
                await websocket.send_json({"type": "content", "data": chunk})
            conversation_history.append({"role": "assistant", "content": full_response})


    except Exception as e:
        print("Unexpected error occurred:", e)
    
    finally:
        await websocket.close()
        


# chat
@app.post("/chat")
def chat_endpoint(body: ChatBody):
    """
    body.history -> [{"role": "user", "content": "..."}]
    body.query -> yeni gelen kullanıcı mesajı
    """
    # 🔄 Geçmişe yeni mesajı ekle
    updated_history = body.history + [{"role": "user", "content": body.query}]

    # 🌐 Web araması ve sıralama
    search_results = search_service.web_search(body.query)
    sorted_results = sort_source_service.sort_sources(body.query, search_results)

    # 🤖 Cevabı üret (GÜNCELLENDİ)
    response = llm_service.generate_response(updated_history, sorted_results)

    return response

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))  # Render platformundan PORT okunuyor, yoksa 8000
    uvicorn.run(app, host="0.0.0.0", port=port)
    