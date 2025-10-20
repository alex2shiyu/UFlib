#!/usr/bin/env python3
import os
import numpy as np

# === 输入和输出目录 ===
src_dir = "/home/sypeng/work/batio3/vasp/alm/prim222-aimd/2_harmonic/iter.0000_almSample"
out_dir = "./"   # 输出在同一目录下

# === 原子符号及个数 ===
elements = ["Ba", "Bi", "O"]
atom_counts = [8, 8, 24]
total_atoms = sum(atom_counts)

# === 获取所有 POSCAR 文件（排序） ===
poscar_files = sorted([f for f in os.listdir(src_dir) if f.endswith(".POSCAR")])
print(f"Found {len(poscar_files)} POSCAR files.")

# === 遍历文件逐一转换 ===
for idx, filename in enumerate(poscar_files, start=1):
    path = os.path.join(src_dir, filename)
    with open(path, "r") as f:
        lines = [line.strip() for line in f if line.strip()]

    # === 读取晶格参数（第3-5行） ===
    # VASP 第2行为缩放因子
    scale = float(lines[1])
    lattice = np.array([list(map(float, lines[i].split())) for i in range(2, 5)]) * scale

    # === 读取原子坐标（找到“Direct”所在行） ===
    try:
        direct_idx = [i for i, line in enumerate(lines) if "Direct" in line or "direct" in line][0]
    except IndexError:
        raise RuntimeError(f"Cannot find 'Direct' line in {filename}")

    coords = np.array([list(map(float, lines[i].split())) for i in range(direct_idx + 1, direct_idx + 1 + total_atoms)])

    # === 组装 QE 格式内容 ===
    output_lines = []

    output_lines.append("CELL_PARAMETERS angstrom")
    for v in lattice:
        output_lines.append(f"{v[0]:18.12f} {v[1]:18.12f} {v[2]:18.12f}")
    output_lines.append("")

    output_lines.append("ATOMIC_POSITIONS crystal")

    start = 0
    for elem, n in zip(elements, atom_counts):
        for j in range(n):
            x, y, z = coords[start + j]
            output_lines.append(f"  {elem:<2s}  {x:16.12f}  {y:16.12f}  {z:16.12f}")
        start += n

    # === 输出文件名 ===
    out_name = f"scf_population1_{idx}.dat"
    out_path = os.path.join(out_dir, out_name)

    with open(out_path, "w") as f:
        f.write("\n".join(output_lines) + "\n")

    print(f"[{idx:02d}] Converted {filename} → {out_name}")

print("✅ All files converted successfully.")

