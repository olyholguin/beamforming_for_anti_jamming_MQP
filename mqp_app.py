# Main Script with createSignal, estimateMUSIC, beamformerMVDR

import numpy as np
import matplotlib.pyplot as plt
import scipy.linalg as lin
import scipy.constants as const

time = np.linspace(0.0, 0.3, 300)
carrier_freq = 100e6
colSp = 0.5
rowSp = 0.4
noise_pwr = 0.05
bjammer = 0.01
doa = [45,0]

def create_signal(time, carrier_freq, colSp, rowSp, noise_pwr, doa):
    pulse = np.zeros_like(time)
    pulse[201:205] = 1

    wavelength = const.c/carrier_freq
    rowSpacing = rowSp * wavelength
    colSpacing = colSp * wavelength

    ura_x, ura_y = np.meshgrid(np.arange(2) * colSpacing, np.arange(2) * rowSpacing)
    ura = np.column_stack((ura_x.ravel(), ura_y.ravel(), np.zeros(2 * 2)))
    ura = ura[np.nonzero(ura)]
    # no_zeros = ura[np.nonzero(ura)] 
    # ura = np.zeros((2, 2))
    # ura[0,0] = no_zeros[0]
    # ura[0,1] = no_zeros[1]
    # ura[1,0] = no_zeros[2]
    # ura[1,1] = no_zeros[3]
    
    n_elements = ura.shape[0]
    n_signals = 1
    n_samples = len(time)
    output = np.zeros((n_elements, n_samples), dtype=complex)
    rad = [doa[0]*np.pi/180, doa[1]*np.pi/180]

    for i in range(n_signals):
        for j in range(n_elements):
            delay = np.dot(ura[j], np.array([np.cos(rad[i]), np.sin(rad[i])])) / carrier_freq
            output[j] += pulse[i] * np.exp(-1j * 2 * np.pi * carrier_freq * delay)
    noise = 0
    return [ura, output, noise]

[ura, x, noise] = create_signal(time, carrier_freq, colSp, rowSp, noise_pwr, doa)

# plt.plot(time, pulse)
# plt.xlabel('Time')
# plt.ylabel('Amplitude')
# plt.title('Rectangular Pulse')
# plt.grid()
# plt.show()
