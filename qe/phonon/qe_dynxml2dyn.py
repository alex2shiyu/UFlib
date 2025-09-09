#!/usr/bin/env python3
import argparse, os, re, sys, math
from typing import List, Tuple
import numpy as np

THZ_TO_CM1 = 33.35640951981521
AMU_TO_RY_MASS = 1822.888486209/2.0

def expand_q_list(q_args):
    out = []
    for token in q_args:
        if "-" in token:
            a,b = token.split("-",1)
            out.extend(range(int(a), int(b)+1))
        else:
            out.append(int(token))
    seen=set(); res=[]
    for x in out:
        if x not in seen:
            seen.add(x); res.append(x)
    return res

def _parse_value(pattern, text, cast=float):
    m = re.search(pattern, text)
    if not m: raise ValueError("Failed to find pattern: "+pattern)
    return cast(m.group(1))

def _parse_list_between(tag, text):
    m = re.search(rf"<{tag}>\s*([\s\S]*?)\s*</{tag}>", text)
    if not m: return []
    return [float(x) for x in m.group(1).split()]

def parse_xml(xml_text):
    ntyp = int(_parse_value(r"<NUMBER_OF_TYPES>(\d+)</NUMBER_OF_TYPES>", xml_text, int))
    nat  = int(_parse_value(r"<NUMBER_OF_ATOMS>(\d+)</NUMBER_OF_ATOMS>", xml_text, int))
    ibrav = int(_parse_value(r"<BRAVAIS_LATTICE_INDEX>(\d+)</BRAVAIS_LATTICE_INDEX>", xml_text, int))
    cell = _parse_list_between("CELL_DIMENSIONS", xml_text); cell = (cell+[0.0]*6)[:6]

    type_names = {}; masses_amu = {}
    for it in range(1, ntyp+1):
        name = re.search(rf"<TYPE_NAME\.{it}>\s*([^<\s]+)\s*</TYPE_NAME\.{it}>", xml_text).group(1)
        mass = float(re.search(rf"<MASS\.{it}>\s*([0-9Ee\+\-\.]+)\s*</MASS\.{it}>", xml_text).group(1))
        type_names[it]=name; masses_amu[it]=mass
    name_to_type = {v:k for k,v in type_names.items()}

    atoms=[]; atom_types=[]
    for ia in range(1, nat+1):
        m = re.search(rf'<ATOM\.{ia}\b[^>]*SPECIES="([^"]+)"[^>]*TAU="([^"]+)"', xml_text)
        species = m.group(1); tau = [float(x) for x in m.group(2).split()]
        itype = name_to_type[species]
        atoms.append((ia, itype, tau)); atom_types.append(itype)

    dyn_blocks = []
    for mblk in re.finditer(r"<DYNAMICAL_MAT_\.(\d+)>\s*([\s\S]*?)\s*</DYNAMICAL_MAT_\.\1>", xml_text):
        blk = mblk.group(2)
        qpt = _parse_list_between("Q_POINT", blk)
        phi = np.zeros((3*nat, 3*nat), dtype=complex)
        for m in re.finditer(r"<PHI\.(\d+)\.(\d+)>\s*([\s\S]*?)\s*</PHI\.\1\.\2>", blk):
            i = int(m.group(1)); j = int(m.group(2))
            data = np.fromstring(m.group(3), sep=' ')
            block = data.reshape(-1,2).view(np.complex128).reshape(3,3)
            phi[3*(i-1):3*i, 3*(j-1):3*j] = block
        dyn_blocks.append({"qpt": qpt, "phi": phi})

    eps = None
    m = re.search(r"<DIELECTRIC_TENSOR>\s*([\s\S]*?)\s*</DIELECTRIC_TENSOR>", xml_text) or re.search(r"<EPSILON>\s*([\s\S]*?)\s*</EPSILON>", xml_text)
    if m:
        nums = [float(x) for x in m.group(1).split()]
        if len(nums)>=9: eps=[nums[0:3], nums[3:6], nums[6:9]]

    zstars=[None]*nat
    mZ = re.search(r"<ZSTAR>\s*([\s\S]*?)\s*</ZSTAR>", xml_text)
    if mZ:
        inner = mZ.group(1)
        for mm in re.finditer(r"<Z_AT_\.(\d+)>\s*([\s\S]*?)\s*</Z_AT_\.\1>", inner):
            idx = int(mm.group(1))
            nums = [float(x) for x in mm.group(2).split()]
            if len(nums)>=9:
                zstars[idx-1] = [nums[0:3], nums[3:6], nums[6:9]]

    freq_thz=[]; freq_cm1=[]; vec=None
    mm = re.search(r"<FREQUENCIES_THZ_CMM1>\s*([\s\S]*?)\s*</FREQUENCIES_THZ_CMM1>", xml_text)
    if mm:
        inner = mm.group(1)
        cols = re.findall(r"<OMEGA\.(\d+)>\s*([^\n<]+)", inner)
        if cols:
            cols_sorted = sorted(((int(k), line.strip()) for k,line in cols), key=lambda x: x[0])
            for _, line in cols_sorted:
                vals = [float(x) for x in line.split()[:2]]
                thz, cm1 = vals if len(vals)==2 else (vals[0], vals[0]*THZ_TO_CM1)
                freq_thz.append(thz); freq_cm1.append(cm1)
        disp_blocks = re.findall(r"<DISPLACEMENT\.(\d+)>\s*([\s\S]*?)\s*</DISPLACEMENT\.\1>", inner)
        if disp_blocks:
            disp_sorted = sorted(((int(k), blk.strip()) for k,blk in disp_blocks), key=lambda x: x[0])
            triplets = []
            for _, blk in disp_sorted:
                nums = [float(x) for x in blk.split()]
                comp = [complex(nums[2*k], nums[2*k+1]) for k in range(len(nums)//2)]
                triplets.append(comp)
            if triplets:
                nm = len(triplets)
                vec = np.zeros((3*nat, nm), dtype=complex)
                for imode in range(nm):
                    for ia in range(nat):
                        vec[3*ia+0, imode] = triplets[imode][3*ia+0]
                        vec[3*ia+1, imode] = triplets[imode][3*ia+1]
                        vec[3*ia+2, imode] = triplets[imode][3*ia+2]

    return {
        "ntyp": ntyp, "nat": nat, "ibrav": ibrav, "cell": cell,
        "type_names": type_names, "masses_amu": masses_amu,
        "atoms": atoms, "dyn_blocks": dyn_blocks,
        "eps": eps, "zstars": zstars,
        "freq_thz": freq_thz, "freq_cm1": freq_cm1, "eigvec": vec
    }

def write_dyn(out_path: str, info: dict, include_modes=True):
    ntyp=info["ntyp"]; nat=info["nat"]; ibrav=info["ibrav"]; cell=info["cell"]
    type_names=info["type_names"]; masses_amu=info["masses_amu"]; atoms=info["atoms"]
    dyn_blocks=info["dyn_blocks"]; eps=info["eps"]; zstars=info["zstars"]

    with open(out_path, "w") as f:
        f.write("Dynamical matrix file\n")
        f.write("Phonons on a uniform grid                                                  \n")
        f.write(f"{ntyp:3d}{nat:5d}{ibrav:4d}"+ "".join(f"{x:12.7f}" for x in cell) +"\n")
        for it in range(1, ntyp+1):
            name = (type_names[it] + "   ")[:4]
            name_q = "'" + name + "'"
            f.write(f"{it:12d}  {name_q:<6s}    {masses_amu[it]*AMU_TO_RY_MASS:16.13f}     \n")
        for (idx, itype, tau) in atoms:
            f.write(f"{idx:5d}{itype:5d}"+ "".join(f"{x:14.10f}" for x in tau) +"\n")

        for b in dyn_blocks:
            qpt = b["qpt"]; phi = b["phi"]
            f.write("\n     Dynamical  Matrix in cartesian axes\n\n")
            f.write(f"     q = ({qpt[0]:13.9f}  {qpt[1]:11.9f}  {qpt[2]:11.9f} ) \n\n")
            for i in range(1, nat+1):
                for j in range(1, nat+1):
                    block = phi[3*(i-1):3*i, 3*(j-1):3*j]
                    f.write(f"{i:5d}{j:5d}\n")
                    for r in range(3):
                        line = ""
                        for c in range(3):
                            z = block[r,c]
                            line += f"{z.real:+13.8f} {z.imag:+13.8f} "
                        f.write(line.rstrip()+"\n")

        if eps is not None:
            f.write("\n     Dielectric Tensor in cartesian axes\n\n")
            for r in range(3):
                f.write(" "+ "".join(f"{eps[r][c]:+15.9f}" for c in range(3)) +"\n")

        if any(z is not None for z in zstars):
            f.write("\nEffective Charges E-U: Z_{alpha}{s,beta}\n\n")
            for ia, z in enumerate(zstars, start=1):
                if z is None: continue
                f.write(f"     atom #    {ia}\n")
                for r in range(3):
                    f.write(" "+ "".join(f"{z[r][c]:+16.12f}" for c in range(3)) +"\n")
            f.write("\nEffective Charges U-E: Z_{s,alpha}{beta}\n\n")
            for ia, z in enumerate(zstars, start=1):
                if z is None: continue
                f.write(f"     atom #    {ia}\n")
                for r in range(3):
                    f.write(" "+ "".join(f"{z[c][r]:16.12f}" for c in range(3)) +"\n")

        qrep = dyn_blocks[0]["qpt"] if dyn_blocks else [0.0,0.0,0.0]
        f.write("\n     Diagonalizing the dynamical matrix\n\n")
        f.write(f"     q = ({qrep[0]:12.9f}  {qrep[1]:12.9f}  {qrep[2]:12.9f} ) \n\n")
        f.write(" **************************************************************************\n")

        if include_modes:
            freq_THz = info.get("freq_thz") or []
            freq_cm1 = info.get("freq_cm1") or []
            vec = info.get("eigvec")
            if freq_THz and vec is not None:
                nm = min(len(freq_THz), vec.shape[1])
               #f.write("\n")
                for imode in range(nm):
                    f.write(f"     freq ({imode+1:4d}) = {float(freq_THz[imode]):+12.6f} [THz] = {float(freq_cm1[imode]):+12.6f} [cm-1]\n")
                    for ia in range(nat):
                        u0,u1,u2 = vec[3*ia+0,imode], vec[3*ia+1,imode], vec[3*ia+2,imode]
                        f.write(f" ( {u0.real:+10.6f} {u0.imag:+10.6f} {u1.real:+10.6f} {u1.imag:+10.6f} {u2.real:+10.6f} {u2.imag:+10.6f} ) \n")
                f.write(" **************************************************************************\n")

def convert_file(xml_file: str, out_file: str):
    with open(xml_file, "r", errors="ignore") as fh:
        text = fh.read()
    info = parse_xml(text)
    write_dyn(out_file, info, include_modes=True)

def main():
    ap = argparse.ArgumentParser(description="Convert QE ph.x dynX.xml -> dynX, multi-q supported; modes from XML")
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--prefix", type=str, help="Prefix of files like PREFIX.dynX.xml")
    g.add_argument("--inputs", nargs="+", help="Explicit list of XML files to convert")
    ap.add_argument("--q", nargs="+", type=str, help="q indices (supports ranges, e.g. 1-5 8 10) for PREFIX.dynX.xml")
    ap.add_argument("--out-suffix", type=str, default="", help="Suffix for output (avoid overwrite)")
    args = ap.parse_args()

    tasks = []
    if args.prefix:
        if not args.q:
            ap.error("When using --prefix, also pass --q")
        q_list = expand_q_list(args.q)
        for X in q_list:
            xml_file = f"{args.prefix}.dyn{X}.xml"
            if not os.path.exists(xml_file):
                print(f"[WARN] Missing file: {xml_file}", file=sys.stderr); continue
            out_file = f"{args.prefix}.dyn{X}{args.out-suffix if hasattr(args,'out-suffix') else args.out_suffix}"
            tasks.append((xml_file, out_file))
    else:
        for xml_file in args.inputs:
            if not os.path.exists(xml_file):
                print(f"[WARN] Missing file: {xml_file}", file=sys.stderr); continue
            base = re.sub(r"\.xml$", "", xml_file)
            out_file = f"{base}{args.out_suffix}"
            tasks.append((xml_file, out_file))

    if not tasks:
        print("No input files found.", file=sys.stderr); sys.exit(2)
    for xml_file, out_file in tasks:
        print(f"[INFO] Converting {xml_file} -> {out_file}")
        convert_file(xml_file, out_file)
    print("[DONE] Conversion complete.")

if __name__ == "__main__":
    main()
