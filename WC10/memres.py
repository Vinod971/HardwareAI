import numpy as np
import matplotlib.pyplot as plt

# Constants
DT = 0.001  # Time step
T = 1       # Total time
freq = 1    # Frequency of the applied voltage
A = 1       # Amplitude of voltage

# Memristor parameters (Biolek model)
Ron = 100      # Low resistance state
Roff = 16000   # High resistance state
D = 10e-9      # Width of the device
uv = 10e-15    # Mobility
x0 = 0.1       # Initial state (between 0 and 1)

def window(x):
    """Biolek window function"""
    return 1 - (2 * x - 1)**2

# Time array
t = np.arange(0, T, DT)
v = A * np.sin(2 * np.pi * freq * t)  # Sinusoidal input
x = np.zeros_like(t)
x[0] = x0
i = np.zeros_like(t)

# Simulate memristor
for n in range(1, len(t)):
    R = Ron * x[n-1] + Roff * (1 - x[n-1])
    i[n] = v[n] / R
    dx = uv * Ron * i[n] / D**2 * window(x[n-1])
    x[n] = x[n-1] + dx * DT
    x[n] = min(max(x[n], 0), 1)  # Clamp x between 0 and 1

# Plot I-V curve
plt.figure(figsize=(8, 6))
plt.plot(v, i, label="Memristor I-V")
plt.xlabel("Voltage (V)")
plt.ylabel("Current (A)")
plt.title("Pinched Hysteresis Loop (Biolek Memristor Model)")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.savefig("memristor_iv_curve.png")
plt.show()
