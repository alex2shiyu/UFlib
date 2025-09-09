Here are notes from Jinsoo and me on using open_grid for the Wannier step.

1. Perform the SCF step, but the k-point grid should match the coarse-grid k-points for the Perturbo run
2. Make a copy of the SCF folder as 'NSCF'
3. In the NSCF folder, run open_grid.x as open_grid.x -i open_grid.in > open_grid.out
Note: I used 1 node, -np 1, -npool 1 to avoid memory issue.

   Sample open_grid.in file:
      &inputpp
      outdir = './tmp'
      prefix = '{prefix}'
      /

4. Replace the {prefix}.save and {prefix}.xml with the newly generated files "{prefix}_open.save" and "{prefix}_open.xml" in the nscf/tmp folder
5. From open_grid.out, extract the k-point grid list and use it to generate a wannier90 input file "{prefix}.win"
6. Run the Wannier90 step as usual
7. Run PHonon calculation as usual (from the SCF folder in step 1)
8. In the QE2PERT step, use the new NSCF folder and the files from wannier90.
