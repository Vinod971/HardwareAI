import wave
import numpy as np
from scipy.fftpack import dct

# Parameters
SAMPLE_RATE = 16000
FRAME_SIZE_MS = 25
FRAME_STRIDE_MS = 10
N_FFT = 512
N_MFCC = 26
INT_BITS = 8

def read_audio_to_pcm(file_path):
    with wave.open(file_path, 'rb') as wav:
        frames = wav.readframes(wav.getnframes())
        samples = np.frombuffer(frames, dtype=np.int16)
    return samples

def frame_signal(signal, frame_size, frame_stride, sample_rate):
    frame_len = int(round(frame_size * sample_rate / 1000))
    frame_step = int(round(frame_stride * sample_rate / 1000))
    signal_len = len(signal)
    num_frames = 1 + int(np.ceil((signal_len - frame_len) / frame_step))
    
    pad_signal_len = num_frames * frame_step + frame_len
    z = np.zeros((pad_signal_len - signal_len))
    pad_signal = np.append(signal, z)

    indices = (
        np.tile(np.arange(0, frame_len), (num_frames, 1)) +
        np.tile(np.arange(0, num_frames * frame_step, frame_step), (frame_len, 1)).T
    )
    frames = pad_signal[indices.astype(np.int32, copy=False)]
    return frames

def apply_hamming(frames):
    hamming = np.hamming(frames.shape[1])
    return frames * hamming

def extract_mfcc(frames, NFFT=512, nfilt=26, num_ceps=26):
    mag_frames = np.absolute(np.fft.rfft(frames, NFFT))
    pow_frames = (1.0 / NFFT) * (mag_frames ** 2)

    low_freq_mel = 0
    high_freq_mel = 2595 * np.log10(1 + (SAMPLE_RATE / 2) / 700)
    mel_points = np.linspace(low_freq_mel, high_freq_mel, nfilt + 2)
    hz_points = 700 * (10**(mel_points / 2595) - 1)
    bin = np.floor((NFFT + 1) * hz_points / SAMPLE_RATE).astype(int)

    fbank = np.zeros((nfilt, N_FFT // 2 + 1))
    for m in range(1, nfilt + 1):
        f_m_minus = bin[m - 1]
        f_m = bin[m]
        f_m_plus = bin[m + 1]
        for k in range(f_m_minus, f_m):
            fbank[m - 1, k] = (k - f_m_minus) / (f_m - f_m_minus)
        for k in range(f_m, f_m_plus):
            fbank[m - 1, k] = (f_m_plus - k) / (f_m_plus - f_m)

    filter_banks = np.dot(pow_frames, fbank.T)
    filter_banks = np.where(filter_banks == 0, np.finfo(float).eps, filter_banks)
    log_fbank = np.log(filter_banks)
    mfcc = dct(log_fbank, type=2, axis=1, norm='ortho')[:, :num_ceps]
    return mfcc

def normalize_and_quantize(mfcc_matrix, bits=8):
    max_int = 2**(bits - 1) - 1
    min_int = -2**(bits - 1)
    max_abs = np.max(np.abs(mfcc_matrix))
    normalized = mfcc_matrix / max_abs
    quantized = np.clip((normalized * max_int).round(), min_int, max_int).astype(np.int8)
    return quantized

def convert_to_bitstrings(matrix):
    bit_matrix = []
    for row in matrix:
        bit_row = [format((int(val) + 256) % 256, '08b') for val in row]  # Convert to unsigned 8-bit binary
        bit_matrix.append(' '.join(bit_row))  # Join bits with spaces
    return bit_matrix


def process_and_save_quantized_bits(file_path, output_txt="mfcc_bitstream_output.txt"):
    signal = read_audio_to_pcm(file_path)
    frames = frame_signal(signal, FRAME_SIZE_MS, FRAME_STRIDE_MS, SAMPLE_RATE)
    windowed = apply_hamming(frames)
    mfcc = extract_mfcc(windowed)
    quantized = normalize_and_quantize(mfcc)
    bit_lines = convert_to_bitstrings(quantized)

    with open(output_txt, 'w') as f:
        f.write('\n'.join(bit_lines))
    
    print(f"✅ Bitstream saved to: {output_txt}")
    return quantized.shape 
if __name__ == "__main__":
    input_wav_file = "temp_audio.wav"  # Replace with your actual .wav file path
    output_file = "mfcc_bitstream_output.txt"

    shape = process_and_save_quantized_bits(input_wav_file, output_file)
    print(f"MFCC bitstream shape (frames × features): {shape}")

