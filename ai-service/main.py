from fastapi import FastAPI, HTTPException
import requests
import json
import threading
import uvicorn
import os

from models import EventData

import py_eureka_client.eureka_client as eureka_client

# =========================
#   Config Globale
# =========================

app = FastAPI(title="ai-service")

# Variables d'environnement
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:30000/api/generate")
MODEL = os.getenv("MODEL", "mistral")
EUREKA_SERVER = os.getenv("EUREKA_SERVER", "https://eureka-server-production-9937.up.railway.app/eureka/")
SERVICE_PORT = int(os.getenv("PORT", "8000"))
SERVICE_HOST = os.getenv("SERVICE_HOST", "localhost")

# =========================
#   Fonctions utilitaires
# =========================

def call_ollama(prompt: str) -> str:
    """
    Envoie un prompt à Ollama et renvoie le champ 'response' en texte brut.
    """
    data = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False
    }

    try:
        response = requests.post(OLLAMA_URL, json=data, timeout=120)
        response.raise_for_status()
        body = response.json()
        return body.get("response", "").strip()
    except requests.RequestException as e:
        raise HTTPException(
            status_code=500,
            detail=f"Erreur lors de l'appel à Ollama : {e}"
        )


def parse_json_or_raise(text: str):
    """
    Essaie de parser la réponse du LLM en JSON.
    Si ça échoue, renvoie une erreur HTTP 500 avec le texte brut pour debug.
    """
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        raise HTTPException(
            status_code=500,
            detail=f"Impossible de parser la réponse du LLM en JSON. Réponse brute : {text}"
        )


# =========================
#   Enregistrement Eureka
# =========================

def init_eureka():
    """
    Fonction appelée dans un thread séparé pour initialiser l'enregistrement Eureka.
    """
    try:
        print(f"[AI-SERVICE] Initialisation Eureka: {EUREKA_SERVER}")
        eureka_client.init(
            eureka_server=EUREKA_SERVER,
            app_name="ai-service",
            instance_port=SERVICE_PORT,
            instance_host=SERVICE_HOST
        )
        print("[AI-SERVICE] ✅ Enregistré avec succès dans Eureka.")
    except Exception as e:
        print(f"[AI-SERVICE] ❌ Erreur lors de l'enregistrement Eureka: {e}")


@app.on_event("startup")
def register_to_eureka():
    """
    Hook FastAPI appelé au démarrage de l'application.
    """
    print("[AI-SERVICE] 🚀 Démarrage : tentative d'enregistrement dans Eureka...")
    t = threading.Thread(target=init_eureka, daemon=True)
    t.start()


# =========================
#   Endpoints IA
# =========================

@app.get("/health")
def health():
    """Endpoint de santé pour Eureka"""
    return {"status": "UP"}


@app.post("/generate-event-content")
def generate_event_content(event: EventData):
    """
    Génère un titre, description et agenda pour l'événement.
    """
    prompt = f"""
Tu es un assistant expert en création d'événements.

Génère pour moi :
1. Un titre d'événement professionnel.
2. Une description complète (5 phrases).
3. Un agenda structuré (3 à 6 parties).

Informations fournies :
- Titre provisoire : {event.title}
- Description actuelle : {event.description}
- Lieu : {event.location}
- Date : {event.eventDate}

IMPORTANT : 
Réponds UNIQUEMENT en JSON valide et en français, sans texte autour, dans ce format exact :

{{
  "title": "Titre généré ici",
  "description": "Description générée ici",
  "agenda": "Agenda généré ici, texte multi-lignes si besoin"
}}
"""

    raw = call_ollama(prompt)
    data = parse_json_or_raise(raw)
    return data


@app.post("/generate-marketing")
def generate_marketing(event: EventData):
    """
    Génère un texte marketing pour l'événement.
    """
    prompt = f"""
Tu es un expert en marketing événementiel.

Génère un texte marketing court et percutant pour promouvoir l'événement suivant : 

- Titre : {event.title}
- Lieu : {event.location}
- Date : {event.eventDate}

IMPORTANT :
Réponds UNIQUEMENT en JSON valide et en français, sans texte autour, dans ce format exact :

{{
  "marketing": "Texte marketing ici"
}}
"""

    raw = call_ollama(prompt)
    data = parse_json_or_raise(raw)
    return data


# =========================
#   Main
# =========================

if __name__ == "__main__":
    # Enregistrement Eureka
    print("[AI-SERVICE] 🚀 Démarrage...")
    t = threading.Thread(target=init_eureka, daemon=True)
    t.start()
    
    uvicorn.run("main:app", host="0.0.0.0", port=SERVICE_PORT, reload=False)
