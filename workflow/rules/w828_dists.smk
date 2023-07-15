# For w828 distances, this is an optional input
# Data already aggregated, no input functions required


rule make_t24_w828_ndx:
    input:
        "runs/{folder}/md_1.tpr",
    output:
        w828_ndx="runs/{folder}/w828_dist.ndx",
    params:
        grp_1="r 828 & a NE1 CD* CE* CG CH2 CZ*",
        grp_2="r 9 & a NZ",
    shell:
        """
        echo -e "{params.grp_1} \n{params.grp_2} \nq" |
        gmx make_ndx -f {input} -o {output}
        """


rule make_t24_w828_xvg:
    input:
        xtc="runs/{folder}/combined.xtc",
        ndx="runs/{folder}/w828_dist.ndx",
    output:
        "results/{folder}/w828_dists/data/w828_to_k9me3.xvg",
    params:
        prefix="runs/{folder}",
    shell:
        """
        gmx distance -f {input.xtc} -s {params.prefix}/{config[md_tpr]} \
                     -n {input.ndx} \
                     -select 'com of group "r_828_&_NE1_CD*_CE*_CG_CH2_CZ*" plus group "r_9_&_NZ"' \
                     -oall {output} -tu ns
        """


rule plot_t24_w828_k9me3_heatmap:
    input:
        rules.make_t24_w828_xvg.output,
    output:
        "results/{folder}/w828_dists/w828_k9me3_dist_heatmap.png",
    params:
        n_runs=N_RUNS,
        title="W828\u2013K9 NZ",
        vmin=3,
        vmax=6,
    script:
        "../scripts/plot_single_heatmap.py"


rule plot_t24_w828_k9me3_kde:
    input:
        rules.make_t24_w828_xvg.output,
    output:
        "results/{folder}/w828_dists/w828_k9me3_dist_kde.png",
    params:
        xmin=3,
        xmax=6,
        xlabel="Distance (Å)",
        dist_on=True,
    script:
        "../scripts/plot_kde.py"
