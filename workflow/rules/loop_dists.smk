# Not an optional input, this is general protein dynamics!
# Data already aggregated, no input functions required


rule make_t24_za_bc_loop_ndx:
    '''
    Group 8 is the protein backbone
    '''
    input:
        "runs/{folder}/md_1.tpr",
    output:
        za_bc_loop_ndx="runs/{folder}/za_bc_loop_dist.ndx",
    params:
        grp_1="r 919-944 & 8",
        grp_2="r 980-985 & 8",
    shell:
        """
        echo -e '{params.grp_1} \n{params.grp_2} \nq' |
        gmx make_ndx -f {input} -o {output}
        """


rule make_t24_za_bc_loop_xvg:
    input:
        xtc="runs/{folder}/combined.xtc",
        ndx="runs/{folder}/za_bc_loop_dist.ndx",
    output:
        "results/{folder}/za_bc_loop_dists/data/za_bc_loop_com_dist.xvg",
    params:
        prefix="runs/{folder}",
    shell:
        """
        gmx distance -f {input.xtc} -s {params.prefix}/{config[md_tpr]} \
                     -n {input.ndx} \
                     -select 'com of group "r_919-944_&_Backbone" plus com of group "r_980-985_&_Backbone"' \
                     -oall {output} -tu ns
        """


rule plot_t24_za_bc_loop_all_heatmaps:
    input:
        rules.make_t24_za_bc_loop_xvg.output,
    output:
        "results/{folder}/za_bc_loop_dists/za_bc_loop_dist_heatmap.png",
    params:
        n_runs=N_RUNS,
        title="ZA loop\u2013BC loop CoM distance",
        vmin=10,
        vmax=20,
    script:
        "../scripts/plot_single_heatmap.py"


rule plot_t24_za_bc_loop_ar_kde:
    input:
        rules.make_t24_za_bc_loop_xvg.output,
    output:
        "results/{folder}/za_bc_loop_dists/za_bc_loop_dist_kde.png",
    params:
        xmin=10,
        xmax=20,
        xlabel="Distance (Å)",
        dist_on=True,
    script:
        "../scripts/plot_kde.py"
