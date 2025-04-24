import speech_recognition as sr
import pyttsx3
import time

# Initialize text-to-speech engine
engine = pyttsx3.init()
voices = engine.getProperty('voices')
engine.setProperty('voice', voices[1].id)  # Set to female voice (usually index 1 for female)

# Function to speak out the text
def speak(text):
    engine.say(text)
    engine.runAndWait()

# Function to recognize speech
def recognize_speech():
    recognizer = sr.Recognizer()
    with sr.Microphone() as source:
        print("🎙 Listening...")
        recognizer.adjust_for_ambient_noise(source)  # Adjust to ambient noise
        audio = recognizer.listen(source, timeout=5)  # Adding timeout of 5 seconds for listening

    try:
        command = recognizer.recognize_google(audio).lower()
        print(f"You said: {command}")
        return command
    except sr.UnknownValueError:
        print("Sorry, I couldn't understand that.")
        return None
    except sr.RequestError:
        print("Sorry, there was an error with the speech service.")
        return None
    except Exception as e:
        print(f"Error: {e}")
        return None

# Function to listen for name
def listen_for_name():
    recognizer = sr.Recognizer()
    with sr.Microphone() as source:
        print("🎙 Listening for the name...")
        audio = recognizer.listen(source, timeout=5)  # Adding timeout of 5 seconds for listening

    try:
        name = recognizer.recognize_google(audio)
        print(f"Name: {name}")
        return name.lower()  # Return name in lowercase for easier comparison
    except sr.UnknownValueError:
        print("Sorry, I couldn't hear the name.")
        return None
    except sr.RequestError:
        print("Sorry, there was an error with the speech service.")
        return None
    except Exception as e:
        print(f"Error: {e}")
        return None

# Main function to listen, recognize and respond
def listen_and_respond():
    recognized_name = None
    print("🎙 Listening...")

    # First, ask for name recognition
    recognized_name = listen_for_name()

    # If the name is not recognized, exit gracefully
    if recognized_name is None:
        print("I couldn't recognize your name. Goodbye!")
        speak("I couldn't recognize your name. Goodbye!")
        return

    # Example of recognized voice sample (you can modify this with your logic)
    if recognized_name == "vinod":  # Replace this with your name or a check for other names
        speak("Hello, I’m Love, your personal assistant. How can I help?")
        while True:
            print("🎙 Listening...")
            audio = recognize_speech()
            if audio:
                if "weather" in audio:
                    print("Love: It's sunny and bright outside! A perfect day.")
                    speak("It's sunny and bright outside! A perfect day.")
                elif "bye" in audio:
                    print("Love: Goodbye!")
                    speak("Goodbye!")
                    break  # Exit the loop when saying "bye"
                else:
                    print("Love: I'm here for you. Ask me anything!")
                    speak("I'm here for you. Ask me anything!")
            else:
                print("I couldn't recognize what you said. Goodbye!")
                speak("I couldn't recognize what you said. Goodbye!")
                break  # Exit if no audio is recognized
    else:
        print("I don't recognize you. I will let my boss know you came.")
        speak("I don't recognize you. I will let my boss know you came.")
        print("Love: Goodbye!")
        speak("Goodbye!")

if __name__ == "__main__":
    print("Initializing Love...")
    speak("Hello, I’m Love, your personal assistant. How can I help?")
    listen_and_respond()
