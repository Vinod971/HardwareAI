def save_sample_voice(filename='my_voice_sample.wav'):
    # This is where you can record your voice and save it as a sample.
    recognizer = sr.Recognizer()
    with sr.Microphone() as source:
        print("Please say something for voice sample...")
        audio = recognizer.listen(source)
        with open(filename, 'wb') as f:
            f.write(audio.get_wav_data())
