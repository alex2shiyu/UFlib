#!/usr/bin/env python3
import os
import numpy as np

# === 常数 ===
ANGSTROM_TO_BOHR = 1.0 / 0.529177  # 1 Å = 1.889725988 Bohr

# === 目录路径 ===
base_dir = "./"
demo_file = os.path.join(base_dir, "scf_demo.dat")

# === 读取 QE 文件函数 ===
def read_qe_file(filepath):
    with open(filepath) as f:
        lines = [l.strip() for l in f if l.strip()]
    cell_start = lines.index("CELL_PARAMETERS angstrom") + 1
    atomic_start = lines.index("ATOMIC_POSITIONS crystal") + 1

    cell = np.array([list(map(float, lines[i].split())) for i in range(cell_start, cell_start + 3)])
    coords = np.array([
        list(map(float, l.split()[1:]))
        for l in lines[atomic_start:]
    ])
    return cell, coords

# === 读取参考结构（无位移） ===
cell_ref, coords_ref = read_qe_file(demo_file)
num_atoms = coords_ref.shape[0]

# === 查找所有 population 文件 ===
qe_files = sorted(
    [f for f in os.listdir(base_dir) if f.startswith("scf_population1_") and f.endswith(".dat")],
    key=lambda s: int(s.split("_")[-1].split(".")[0])
)

print(f"Found {len(qe_files)} population files. Reference: scf_demo.dat")

# === 遍历并生成位移文件 ===
for qe_file in qe_files:
    path = os.path.join(base_dir, qe_file)
    cell, coords = read_qe_file(path)

    # 分数坐标位移（不做周期性修正）
    disp_frac = coords - coords_ref

    # 转换为绝对位移 (Å)
    disp_ang = disp_frac @ cell

    # 转换为 Bohr
    disp_bohr = disp_ang * ANGSTROM_TO_BOHR

    # 输出文件
    out_name = "u_" + qe_file.replace("scf_", "")
    out_path = os.path.join(base_dir, out_name)

    np.savetxt(out_path, disp_bohr, fmt="%18.12f")

    print(f"Generated {out_name} ({num_atoms} atoms)")

print("\n✅ All displacement files generated successfully in Bohr units.")

