import google.generativeai as genai
from config import Settings

settings = Settings()


class LLMService:
    def __init__(self):
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel("gemini-2.0-flash-exp")

    def generate_response(self, history: list[dict], search_results: list[dict]):
        search_results = search_results[:3]
        if len(history) > 4:
            history = history[-4:]
        """
        history: [{"role": "user"/"assistant", "content": "..."}]
        search_results: web arama sonuçları
        """

        context_text = "\n\n".join(
            [
                f"Source {i+1} ({result['url']}):\n{result['content'][:500]}"
                for i, result in enumerate(search_results)
            ]
        )
        chat_history_text = ""
        for message in history:
            role = message["role"].capitalize()
            content = message["content"]
            chat_history_text += f"{role}: {content}\n"


        full_prompt = f"""
You are a helpful AI assistant. Use only the following web search context unless absolutely necessary.

--- WEB CONTEXT START ---
{context_text}
--- WEB CONTEXT END ---

--- CHAT HISTORY START ---
{chat_history_text}
--- CHAT HISTORY END ---

Now continue the conversation based on the last user message.
Respond clearly, with detail, and cite sources like (Source 2) if relevant.
"""

        response = self.model.generate_content(full_prompt, stream=True)

        for chunk in response:
            yield chunk.text