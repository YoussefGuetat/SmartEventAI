from fastapi import FastAPI, HTTPException
import requests
import json
import threading
import uvicorn

from models import EventData   # Ton Pydantic model

import py_eureka_client.eureka_client as eureka_client

# =========================
#   Config Globale
# =========================

app = FastAPI(title="ai-service")

# URL du serveur Ollama (que tu as lancé sur le port 30000)
OLLAMA_URL = "http://localhost:30000/api/generate"
MODEL = "mistral"


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
        # Ollama renvoie un JSON du type {"model":"...","created_at":"...","response":"...","done":true,...}
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
        print("[AI-SERVICE] Initialisation Eureka dans un thread séparé...")
        eureka_client.init(
            eureka_server="http://localhost:8761/eureka/",
            app_name="ai-service",     # le nom qui apparaîtra dans Eureka
            instance_port=8000,
            instance_host="localhost"
        )
        print("[AI-SERVICE] Enregistré avec succès dans Eureka.")
    except Exception as e:
        print(f"[AI-SERVICE] Erreur lors de l'enregistrement Eureka (thread): {e}")


@app.on_event("startup")
def register_to_eureka():
    """
    Hook FastAPI appelé au démarrage de l'application.
    On lance ici l'enregistrement Eureka dans un thread séparé.
    """
    print("[AI-SERVICE] Démarrage : tentative d'enregistrement dans Eureka...")
    t = threading.Thread(target=init_eureka, daemon=True)
    t.start()


# =========================
#   Endpoints IA
# =========================

@app.post("/generate-event-content")
def generate_event_content(event: EventData):
    """
    Génère :
    - un titre d'événement
    - une description
    - un agenda

    à partir des infos de l'événement.
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
    return data   # FastAPI renvoie ce dict en JSON


@app.post("/generate-marketing")
def generate_marketing(event: EventData):
    """
    Génère un texte marketing court et percutant pour promouvoir l'événement.
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
    return data   # {"marketing": "..."} sera renvoyé en JSON


# =========================
#   Main (lancement local)
# =========================

if __name__ == "__main__":
    # Lancement manuel du serveur (si tu lances `python main.py`)
    uvicorn.run("main:app", host="localhost", port=8000, reload=True)
