# Getting water density


rule get_water_density:
    """
    Gets water density
    """
    input:
        tpr="runs/{folder}/em.tpr",
        xtc="runs/{folder}/combined_wat.xtc",
    output:
        "results/{folder}/water_density/water.dx",
    script:
        "../scripts/mda_water_density.py"


rule plot_water_density:
    """
    Plots water density in PyMOL
    Important to use complex_ions.pdb here
    - Waters removed, so the only waters are from complex.gro (the
      crystallographic waters)
    - remove complex_ions after aligning, otherwise I have many atoms
    - Aligning to complex_ions seems to help with getting consistent views
      across different crystal structures

    Saves a png at different sigma levels, xtal waters only
    Hide resi 125 for consistency
    """
    input:
        complex="runs/{folder}/complex.gro",
        complex_ions="runs/{folder}/complex_ions.pdb",
        water=rules.get_water_density.output,
    output:
        pymol_script="results/{folder}/water_density/water.pml",
        pse="results/{folder}/water_density/water_density.pse",
        png_20="results/{folder}/water_density/water_xtal_2.0.png",
        png_15="results/{folder}/water_density/water_xtal_1.5.png",
        png_10="results/{folder}/water_density/water_xtal_1.0.png",
    shell:
        """
        echo -e "load {input.complex} \
                 \nload {input.complex_ions} \
                 \nload {input.water} \
                 \nalign complex, complex_ions \
                 \ndelete complex_ions \
                 \nremove resi 125
                 \nextract bd_wat, resname HOH \
                 \nhide sticks lines \
                 \nshow lines, resi 18 and not name H* \
                 \nshow spheres, bd_wat and name OW \
                 \nset sphere_scale, 0.2, bd_wat \
                 \n \
                 \nisomesh mesh_2.0, water, 2.0, bd_wat \
                 \nisomesh mesh_1.5, water, 1.5, bd_wat \
                 \nisomesh mesh_1.0, water, 1.0, bd_wat \
                 \nisomesh mesh_all_2.0, water, 2.0 \
                 \nisomesh mesh_all_1.5, water, 1.5 \
                 \nisomesh mesh_all_1.0, water, 1.0 \
                 \nhide mesh, mesh_all* \
                 \nset mesh_width, 1.5 \
                 \nset mesh_color, gray50 \
                 \nset_view (\\ \
                     \n0.480707824,   -0.125814945,    0.867797494,\\ \
                     \n0.472944975,    0.870564580,   -0.135769770,\\ \
                     \n-0.738398254,    0.475693882,    0.477996349,\\ \
                     \n-0.000945883,   -0.000260605,  -69.890869141,\\ \
                     \n52.444442749,   79.152801514,   30.923976898,\\ \
                     \n-33841.195312500, 33980.722656250,   20.000000000 ) \
                 \n \
                 \nsel PHD, resi 822-873 \
                 \nsel linker, resi 874-900 \
                 \nsel bromodomain, resi 901-1007 \
                 \nsel peptide, resi 1-21 \
                 \n \
                 \nutil.cba('palegreen', 'PHD') \
                 \nutil.cba('helium', 'linker') \
                 \nutil.cba('lightpink', 'bromodomain') \
                 \nutil.cba('36', 'peptide') \
                 \n \
                 \nsave {output.pse} \
                 \nhide mesh, mesh_1.* \
                 \npng {output.png_20}, ray=1, dpi=600, height=1000, width=1000 \
                 \nshow mesh, mesh_1.5 \
                 \nhide mesh, mesh_2.0 \
                 \npng {output.png_15}, ray=1, dpi=600, height=1000, width=1000 \
                 \nhide mesh, mesh_1.5 \
                 \nshow mesh, mesh_1.0 \
                 \npng {output.png_10}, ray=1, dpi=600, height=1000, width=1000 \
                 \nhide mesh, mesh_1.0 \
                 \nshow mesh, mesh_1.5 \
                 \ndeselect" > {output.pymol_script}
        pymol -c {output.pymol_script}
        """
