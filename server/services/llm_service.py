import google.generativeai as genai
from config import Settings

settings = Settings()

class LLMService:
    def __init__(self):
        genai.configure(api_key=settings.GEMINI_API_KEY)
        
        # Şu an en stabil ve çalışan modellerden biri:
        self.model = genai.GenerativeModel("gemini-2.5-flash")   # veya aşağıdakilerden birini dene

    def build_full_prompt(self, history: list[dict], search_results: list[dict]) -> str:
        print("Search result lengths:", [len(r.get('content', '')) for r in search_results])
        
        context_text = "\n\n".join(
            [
                f"Source {i+1} (URL: {result.get('url', 'No URL')}):\n{result.get('content', 'No content')[:12000]}"
                for i, result in enumerate(search_results)
            ]
        )

        history_text = ""
        for msg in history:
            role = "User" if msg["role"] == "user" else "Assistant"
            history_text += f"{role}: {msg['content']}\n"

        prompt = f"""Sen yardımcı bir Türkçe AI asistanısın. Sadece verilen web bağlamını kullanarak cevap ver.

--- WEB BAĞLAMI BAŞLANGIÇ ---
{context_text}
--- WEB BAĞLAMI BİTİŞ ---

--- SOHBET GEÇMİŞİ ---
{history_text}
--- SOHBET GEÇMİŞİ BİTİŞ ---

Kurallar:
- Türkçe, akıcı ve detaylı cevap ver.
- Kaynak belirt: (Kaynak 1), (Kaynak 2) gibi.
- Direkt konuya gir, sadece link listesi yapma.

Cevap:"""

        return prompt.strip()

    def generate_response(self, history: list[dict], search_results: list[dict]):
        prompt = self.build_full_prompt(history, search_results)
        
        try:
            response = self.model.generate_content(prompt, stream=True)
            for chunk in response:
                if chunk.text:
                    yield chunk.text
        except Exception as e:
            print(f"Gemini API Error: {e}")
            yield "Üzgünüm, şu anda bir sorun oluştu. Lütfen tekrar deneyin."