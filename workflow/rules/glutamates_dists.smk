# For looking at R17 to D926 and E985 distances
# Usually using rules.name_of_rule.output[0] to refer to files for plotting


rule make_t24_glutamates_ndx:
    input:
        "runs/{folder}/md_1.tpr",
    output:
        "runs/{folder}/glutamate_dist.ndx",
    shell:
        """
        mkdir -p results/{wildcards.folder}/glutamate_dists/data
        echo -e "r 926 & a CG \n \
                 r 985 & a CD \n \
                 r 17 & a CZ \n q" |
                 gmx make_ndx -f {input} -o {output}
        """


rule make_t24_d926_xvgs:
    input:
        xtc="runs/{folder}/combined.xtc",
        ndx="runs/{folder}/glutamate_dist.ndx",
    output:
        "results/{folder}/glutamate_dists/data/d926_r17_cz.xvg",
    params:
        prefix="runs/{folder}",
    shell:
        """
        gmx distance -f {input.xtc} -s {params.prefix}/{config[md_tpr]} \
                     -n {input.ndx} \
                     -select 'group "r_926_&_CG" plus group "r_17_&_CZ"' \
                     -oall {output} -tu ns
        """


rule make_t24_e985_xvgs:
    input:
        xtc="runs/{folder}/combined.xtc",
        ndx="runs/{folder}/glutamate_dist.ndx",
    output:
        "results/{folder}/glutamate_dists/data/e985_r17_cz.xvg",
    params:
        prefix="runs/{folder}",
    shell:
        """
        gmx distance -f {input.xtc} -s {params.prefix}/{config[md_tpr]} \
                     -n {input.ndx} \
                     -select 'group "r_985_&_CD" plus group "r_17_&_CZ"' \
                     -oall {output} -tu ns
        """


rule plot_glu_violins:
    '''
    Output of previous rules needs to be supplied as a file not a list
    (this applies to all the plotting rules in this file)
    '''
    input:
        glu_1_r17=rules.make_t24_d926_xvgs.output[0],
        glu_2_r17=rules.make_t24_e985_xvgs.output[0],
    output:
        "results/{folder}/glutamate_dists/glutamate_violins.png",
    params:
        glu_1="D926",
        glu_2="E985",
    script:
        "../scripts/plot_glutamates_violins.py"


rule plot_t24_d926_e985_r17_heatmaps:
    """
    Make 2 heatmaps side-by-side
    Here, lig_1 and lig_2 atoms are the same (R17)
    """
    input:
        f1=rules.make_t24_d926_xvgs.output[0],
        f2=rules.make_t24_e985_xvgs.output[0],
    output:
        "results/{folder}/glutamate_dists/D926_E985_R17_heatmap.png",
    params:
        pro_1="D926",
        pro_2="E985",
        lig_1="R17",
        lig_2="R17",
        vmin=2,
        vmax=15,
        n_runs=N_RUNS,
    script:
        "../scripts/plot_double_heatmap.py"


rule make_t24_d926_xvgs_clip_10ns:
    input:
        xtc="runs/{folder}/combined_clip_10ns.xtc",
        ndx="runs/{folder}/glutamate_dist.ndx",
    output:
        "results/{folder}/glutamate_dists/data/clip_d926_r17_cz.xvg",
    params:
        prefix="runs/{folder}",
    shell:
        """
        gmx distance -f {input.xtc} -s {params.prefix}/{config[md_tpr]} \
                     -n {input.ndx} \
                     -select 'group "r_926_&_CG" plus group "r_17_&_CZ"' \
                     -oall {output} -tu ns
        """


rule make_t24_e985_xvgs_clip_10ns:
    input:
        xtc="runs/{folder}/combined_clip_10ns.xtc",
        ndx="runs/{folder}/glutamate_dist.ndx",
    output:
        "results/{folder}/glutamate_dists/data/clip_e985_r17_cz.xvg",
    params:
        prefix="runs/{folder}",
    shell:
        """
        gmx distance -f {input.xtc} -s {params.prefix}/{config[md_tpr]} \
                     -n {input.ndx} \
                     -select 'group "r_985_&_CD" plus group "r_17_&_CZ"' \
                     -oall {output} -tu ns
        """


rule plot_glu_violins_clip_10ns:
    input:
        glu_1_r17=rules.make_t24_d926_xvgs_clip_10ns.output[0],
        glu_2_r17=rules.make_t24_e985_xvgs_clip_10ns.output[0],
    output:
        "results/{folder}/glutamate_dists/glutamate_violins_clip_10ns.png",
    params:
        glu_1="D926",
        glu_2="E985",
    script:
        "../scripts/plot_glutamates_violins.py"
