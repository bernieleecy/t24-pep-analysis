# For F979 distances
# Data already aggregated, no input functions required


rule make_t24_f979_ndx:
    input:
        "runs/{folder}/md_1.tpr",
    output:
        "runs/{folder}/f979_dist.ndx",
    params:
        grp_1="r 979 & a CD* CE* CG CZ",
        grp_2="r 935 & a CD* CE* CG CZ",
    shell:
        """
        echo -e "{params.grp_1} \n{params.grp_2} \nq" |
        gmx make_ndx -f {input} -o {output}
        """


rule make_t24_f979_xvgs:
    input:
        xtc="runs/{folder}/combined.xtc",
        ndx="runs/{folder}/f979_dist.ndx",
    output:
        "results/{folder}/f979_dists/data/f979_y935.xvg",
    params:
        prefix="runs/{folder}",
    shell:
        """
        gmx distance -f {input.xtc} -s {params.prefix}/{config[md_tpr]} \
                     -n {input.ndx} \
                     -select 'com of group "r_979_&_CD*_CE*_CG_CZ" plus com of group "r_935_&_CD*_CE*_CG_CZ"' \
                     -oall {output} -tu ns
        """


rule plot_t24_f979_y935_heatmap:
    input:
        rules.make_t24_f979_xvgs.output,
    output:
        "results/{folder}/f979_dists/F979_Y935_heatmap.png",
    params:
        vmin=3.5,
        vmax=12,
        title="Y935\u2013F979",
        n_runs=N_RUNS,
    script:
        "../scripts/plot_single_heatmap.py"


rule plot_t24_y935_f979_kde:
    input:
        rules.make_t24_f979_xvgs.output,
    output:
        "results/{folder}/f979_dists/F979_Y935_kde.png",
    params:
        xmin=3.5,
        xmax=12,
    script:
        "../scripts/plot_kde.py"


rule make_t24_f979_xvgs_clip_10ns:
    input:
        xtc="runs/{folder}/combined_clip_10ns.xtc",
        ndx="runs/{folder}/f979_dist.ndx",
    output:
        "results/{folder}/f979_dists/data/clip_f979_y935.xvg",
    params:
        prefix="runs/{folder}",
    shell:
        """
        gmx distance -f {input.xtc} -s {params.prefix}/{config[md_tpr]} \
                     -n {input.ndx} \
                     -select 'com of group "r_979_&_CD*_CE*_CG_CZ" plus com of group "r_935_&_CD*_CE*_CG_CZ"' \
                     -oall {output} -tu ns
        """


rule plot_t24_y935_f979_kde_clip_10ns:
    input:
        f1=rules.make_t24_f979_xvgs_clip_10ns.output,
    output:
        "results/{folder}/f979_dists/F979_Y935_kde_clip_10ns.png",
    params:
        xmin=3.5,
        xmax=12,
    script:
        "../scripts/plot_kde.py"
