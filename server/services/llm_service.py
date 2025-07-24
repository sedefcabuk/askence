import google.generativeai as genai
from config import Settings

settings = Settings()

class LLMService:
    def __init__(self):
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel("gemini-2.0-flash-exp")  # Gerekirse pro modelle değiştir

    def build_full_prompt(self, history: list[dict], search_results: list[dict]) -> str:
        """
        Geçmiş mesajlar ve web arama sonuçlarını içeren bir prompt inşa eder.
        """
        # 1. Web bağlamını birleştir
        context_text = "\n\n".join(
            [
                f"Source {i+1} ({result['url']}):\n{result['content']}"
                for i, result in enumerate(search_results)
            ]
        )

        # 2. Mesaj geçmişini yazıya dök
        history_text = ""
        for msg in history:
            role = "User" if msg["role"] == "user" else "Assistant"
            history_text += f"{role}: {msg['content']}\n"

        # 3. Prompt'u oluştur
        prompt = f"""
You are a helpful AI assistant. Use only the following web search context unless absolutely necessary.

--- WEB CONTEXT START ---
{context_text}
--- WEB CONTEXT END ---

--- CHAT HISTORY START ---
{history_text}
--- CHAT HISTORY END ---

Continue the conversation.
Respond clearly, with detail, and cite sources like (Source 2) if relevant.
"""
        return prompt.strip()

    def generate_response(self, history: list[dict], search_results: list[dict]):
        prompt = self.build_full_prompt(history, search_results)
        
        # Chat objesi yerine doğrudan prompt gönderiyoruz
        response = self.model.generate_content(prompt, stream=True)

        for chunk in response:
            yield chunk.text
