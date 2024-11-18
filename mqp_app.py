# Main Script with createSignal, estimateMUSIC, beamformerMVDR

import numpy as np
import matplotlib.pyplot as plt
import scipy.signal as sig
import scipy.linalg as lin
from scipy.linalg import eig, eigh
import scipy.constants as const
import pyroomacoustics as pra

time = np.linspace(0.0, 0.3, 300)
carrier_freq = 100e6
colSp = 0.5
rowSp = 0.4
noise_pwr = 0.05
bjammer = 0.01
doa = [45,0]

def create_signal(time, carrier_freq, colSp, rowSp, noise_pwr, doa):
    pulse = np.zeros_like(time)
    pulse[101:205] = 1

    wavelength = const.c/carrier_freq
    rowSpacing = rowSp * wavelength
    colSpacing = colSp * wavelength

    ura_x, ura_y = np.meshgrid(np.arange(2) * colSpacing, np.arange(2) * rowSpacing)
    ura = np.column_stack((ura_x.ravel(), ura_y.ravel(), np.zeros(2 * 2)))
    ura = ura[np.nonzero(ura)]
    
    n_elements = ura.shape[0]
    n_signals = 300
    n_samples = len(time)
    output = np.zeros((n_samples, n_elements), dtype=complex)
    rad = [doa[0]*np.pi/180, doa[1]*np.pi/180]

    for i in range(n_signals):
        for j in range(n_elements):
            delay = np.dot(ura[j], np.array([np.cos(rad[0]), np.sin(rad[1])])) / carrier_freq
            delay_new = delay[0]
            output[i,j] += pulse[i] * np.exp(-1j * 2 * np.pi * carrier_freq * delay_new)
    noise = 0
    return [ura, output, noise, pulse]


def estimate_MUSIC(R, M, num_sources):
    # R: Covariance matrix of the received signals.
    # M: Number of sensors in the array.
    # num_sources: Number of sources to estimate.
    # doa_estimates: Estimated DOAs in radians.

    # Eigen decomposition of the covariance matrix
    eigenvalues, eigenvectors = eigh(R)

    # Sort the eigenvalues in descending order
    idx = np.argsort(eigenvalues)[::-1]
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]

    # Construct the noise subspace
    # noise_subspace = eigenvectors[:, num_sources:]
    noise_subspace = eigenvectors[296:, :]

    # Compute the MUSIC spectrum
    # doa_range = np.linspace(-np.pi / 2, np.pi / 2, 360)
    doa_range = np.linspace(-np.pi, np.pi, 360)
    music_spectrum = np.zeros(len(doa_range))

    for i, doa in enumerate(doa_range):
        steering_vector = np.exp(1j * 2 * np.pi * np.arange(M) * np.sin(doa))
        music_spectrum[i] = 1 / np.abs(steering_vector.conj().T @ noise_subspace @ noise_subspace.conj().T @ steering_vector)

    # Find the peaks in the MUSIC spectrum
    doa_estimates = doa_range[np.argsort(music_spectrum)[-num_sources:]]

    return doa_estimates, eigenvectors

def beamformer_MVDR(x, d, R):
    # x (numpy.ndarray): Array of received signals (channels x samples)
    # d (numpy.ndarray): Steering vector (channels x 1)
    # R (numpy.ndarray): Covariance matrix (channels x channels)
    # numpy.ndarray: Beamformed output signal (samples x 1)

    # Compute the inverse of the covariance matrix
    R_inv = lin.inv(R)

    # Compute the MVDR weights
    w = R_inv @ d / (d.conj().T @ R_inv @ d)

    # Apply the beamformer to the received signals
    y = w.conj().T @ x

    return y


[ura, x, noise, pulse] = create_signal(time, carrier_freq, colSp, rowSp, noise_pwr, doa)

# Generate sample data
M = 4  # Number of sensors
num_sources = 1
doa_true = np.array([np.pi / 4, -np.pi / 6])  # True DOAs
doa_true[0] = doa[0]*np.pi/180
doa_true[1] = doa[1]*np.pi/180

# Generate received signals
# R = np.cov(np.random.randn(M, 1000))  # Example covariance matrix
R = np.cov(x)
# R = x

# Estimate DOAs using MUSIC
# doa_estimates, eigenvectors = estimate_MUSIC(R, M, num_sources)
doa_estimates = doa



# Define microphone array geometry
R = np.array([[0, 0], [1, 0]])  # Example: 2 microphones on x-axis

# Create a MUSIC estimator
doa = pra.doa.MUSIC(R, fs=100e6, nfft=512)

# Perform DOA estimation
X = sig.stft(x)  # STFT of the received signal
doa.locate_sources(X, freq_bins=np.arange(20, 40))

# Access the estimated DOAs
print("DoA info: ", doa.azimuth_recon)



# print("True DOAs:", doa_true)
# print("Estimated DOAs:", doa_estimates)

# output = beamformer_MVDR(x, doa_estimates, R)

# plt.plot(time, abs(x))
# plt.plot(time, abs(pulse))
# plt.xlabel('Time')
# plt.ylabel('Amplitude')
# plt.title('Output')
# plt.grid()
# plt.show()

# eig_real = np.real(eigenvectors)

# plt.matshow(eig_real)
# plt.colorbar()  # Add a colorbar to interpret the values
# plt.show()