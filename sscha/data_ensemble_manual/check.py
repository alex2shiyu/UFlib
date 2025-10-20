#!/usr/bin/env python3
import os
import numpy as np

# === 路径设置 ===
base_dir = "/home/sypeng/work/batio3/vasp/alm/prim222-aimd/2_harmonic/iter.0000_almSample"
poscar_dir = base_dir
qe_dir = "./"  # 输出在同一目录下

# === 元素与数量（必须与转换脚本一致）===
elements = ["Ba", "Bi", "O"]
atom_counts = [8, 8, 24]
total_atoms = sum(atom_counts)

# === 容差阈值 ===
LATTICE_THR = 1e-10
COORD_THR   = 1e-6

# === 按自然顺序排列 ===
def natural_sort_key(s):
    import re
    return [int(t) if t.isdigit() else t for t in re.split(r'(\d+)', s)]

poscar_files = sorted(
    [f for f in os.listdir(poscar_dir) if f.endswith(".POSCAR")],
    key=natural_sort_key
)
qe_files = sorted(
    [f for f in os.listdir(qe_dir) if f.startswith("scf_population1_") and f.endswith(".dat")],
    key=natural_sort_key
)

# === 数量检查 ===
if len(poscar_files) != len(qe_files):
    print(f"⚠️ 文件数量不匹配: {len(poscar_files)} POSCAR vs {len(qe_files)} QE dat")
    exit(1)

# === 元素索引定位函数 ===
def element_for_index(idx):
    count = 0
    for elem, n in zip(elements, atom_counts):
        if idx < count + n:
            return elem
        count += n
    return "?"

# === 主循环 ===
all_pass = True

for idx in range(len(poscar_files)):
    poscar_name = poscar_files[idx]
    qe_name = qe_files[idx]
    poscar_path = os.path.join(poscar_dir, poscar_name)
    qe_path = os.path.join(qe_dir, qe_name)

    # ---- 读取 POSCAR ----
    with open(poscar_path) as f:
        lines = [l.strip() for l in f if l.strip()]
    scale = float(lines[1])
    lattice_vasp = np.array([list(map(float, lines[i].split())) for i in range(2, 5)]) * scale
    direct_idx = [i for i, l in enumerate(lines) if "Direct" in l or "direct" in l][0]
    coords_vasp = np.array([
        list(map(float, lines[i].split()))
        for i in range(direct_idx + 1, direct_idx + 1 + total_atoms)
    ])

    # ---- 读取 QE 文件 ----
    with open(qe_path) as f:
        lines = [l.strip() for l in f if l.strip()]
    cell_start = lines.index("CELL_PARAMETERS angstrom") + 1
    atomic_start = lines.index("ATOMIC_POSITIONS crystal") + 1
    lattice_qe = np.array([list(map(float, lines[i].split())) for i in range(cell_start, cell_start + 3)])
    coords_qe = np.array([
        list(map(float, l.split()[1:]))
        for l in lines[atomic_start:atomic_start + total_atoms]
    ])

    # ---- 对比误差 ----
    lat_diff = np.abs(lattice_qe - lattice_vasp)
    coord_diff = np.abs(coords_qe - coords_vasp)
    lat_err = np.max(lat_diff)
    coord_err = np.max(coord_diff)

    if lat_err < LATTICE_THR and coord_err < COORD_THR:
        print(f"[{idx+1:02d}] ✅ {poscar_name} ↔ {qe_name} | lattice diff={lat_err:.2e}, coord diff={coord_err:.2e}")
    else:
        all_pass = False
        print(f"[{idx+1:02d}] ❌ {poscar_name} ↔ {qe_name}")
        print(f"     lattice diff max = {lat_err:.3e}")
        print(f"     coord diff   max = {coord_err:.3e}")

        # 找出最大差异对应的原子
        atom_idx = np.unravel_index(np.argmax(coord_diff), coord_diff.shape)[0]
        elem = element_for_index(atom_idx)
        diff_vec = coord_diff[atom_idx]
        print(f"        → Max difference at Atom #{atom_idx+1:02d} ({elem}) "
              f"Δ = ({diff_vec[0]:.3e}, {diff_vec[1]:.3e}, {diff_vec[2]:.3e})")

print("\n================ Summary ================")
if all_pass:
    print("🎉 All files passed the accuracy check within thresholds!")
else:
    print("⚠️ Some files exceeded tolerance — see above for details.")

