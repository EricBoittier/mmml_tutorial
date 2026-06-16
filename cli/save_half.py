import numpy as np

data = np.load("output_from_md.npz", allow_pickle=True)
half_data = {}

frame_size = None

# frame size'ı otomatik bul (5000)
for key in data.files:
    arr = data[key]
    if arr.ndim > 0:
        frame_size = max(arr.shape)
        break

half = frame_size // 2

for key in data.files:
    arr = data[key]

    if arr.ndim > 0 and arr.shape[0] == frame_size:
        half_data[key] = arr[:half]
    else:
        half_data[key] = arr
np.savez_compressed("output_from_md2.npz", **half_data)
