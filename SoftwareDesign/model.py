# Real-time interactive voice assistant named "Love"
# Offline version using Vosk + Transformers + pyttsx3

import os
import queue
import sounddevice as sd
import vosk
import sys
import json
import pyttsx3
from transformers import pipeline

# Initialize voice engine
engine = pyttsx3.init()
engine.setProperty('rate', 150)
engine.setProperty('volume', 1.0)
voices = engine.getProperty('voices')
# Try to select female voice
female_voice_found = False
for voice in voices:
    if 'female' in voice.name.lower() or 'zira' in voice.id.lower():
        engine.setProperty('voice', voice.id)
        female_voice_found = True
        break
if not female_voice_found:
    print("Female voice not found. Using default voice.")

def speak(text):
    print(f"Love: {text}")
    engine.say(text)
    engine.runAndWait()

# Load Vosk model
if not os.path.exists("model" or "vosk-model-small-en-us-0.15"):
    print("Please download the Vosk model and unpack as 'model' in the current folder.")
    sys.exit(1)

model = vosk.Model("model")
q = queue.Queue()

def callback(indata, frames, time, status):
    if status:
        print(status, file=sys.stderr)
    q.put(bytes(indata))

# Basic AI pipeline for response (intent detection)
classifier = pipeline("text-classification", model="distilbert-base-uncased-finetuned-sst-2-english")

# Map intents to actions/responses
def process_command(command):
    command = command.lower()
    if "news" in command:
        return "Here's the latest news: nothing serious, just enjoy the day."
    elif "weather" in command:
        return "It's sunny and bright outside! A perfect day."
    elif "alarm" in command or "reminder" in command:
        return "Alarm has been set. Don't forget to smile!"
    elif "open" in command:
        return "Opening the requested file or app... at least in my imagination."
    elif "bye" in command or "exit" in command:
        return "Goodbye! Have a lovely day!"
    else:
        return "I'm here for you. Ask me anything!"

# Start assistant
def main():
    speak("Hello, I’m Love, your personal assistant. How can I help?")
    with sd.RawInputStream(samplerate=16000, blocksize=8000, dtype='int16',
                           channels=1, callback=callback):
        rec = vosk.KaldiRecognizer(model, 16000)
        while True:
            data = q.get()
            if rec.AcceptWaveform(data):
                result = json.loads(rec.Result())
                text = result.get("text", "")
                if text:
                    print(f"You said: {text}")
                    response = process_command(text)
                    speak(response)
                    if "goodbye" in response.lower():
                        break

if __name__ == '__main__':
    main()
