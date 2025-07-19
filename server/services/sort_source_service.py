from typing import List
import numpy as np
from sentence_transformers import SentenceTransformer

class SortSourceService: 

    def __init__(self):
        self.embedding_model = SentenceTransformer("all-miniLM-L6-v2")

    def sort_sources(self, query: str, search_results: List[dict]):
        relevant_docs = []
        
        filtered_results = [
            res for res in search_results
            if isinstance(res.get('content'), str) and res['content'].strip()
        ]

        query_embedding = self.embedding_model.encode(query)

        for res in filtered_results:
            res_embedding = self.embedding_model.encode(res['content'])

            similarity = float(
                np.dot(query_embedding, res_embedding) /
                (np.linalg.norm(query_embedding) * np.linalg.norm(res_embedding))
            )

            res['relevance_score'] = similarity

            if similarity > 0.3:
                relevant_docs.append(res)
        
        return sorted(relevant_docs, key=lambda x: x["relevance_score"], reverse=True)
