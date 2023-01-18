# Distances to Y935 (mostly for K18Ac)
# Data already aggregated, no input functions required


rule make_t24_y935_ndx:
    input:
        "runs/{folder}/md_1.tpr",
    output:
        y935_ndx="runs/{folder}/y935_dist.ndx",
    params:
        grp_1="r 935 & a OH",
        grp_2="r 18 & a OH",
    shell:
        """
        mkdir -p results/{wildcards.folder}/y935_dists/data
        echo -e "{params.grp_1} \n{params.grp_2} \nq" |
        gmx make_ndx -f {input} -o {output}
        """


rule make_t24_y935_xvg:
    input:
        xtc="runs/{folder}/combined.xtc",
        ndx="runs/{folder}/y935_dist.ndx",
    output:
        "results/{folder}/y935_dists/data/y935_oh_k18ac.xvg",
    params:
        prefix="runs/{folder}",
    shell:
        """
        gmx distance -f {input.xtc} -s {params.prefix}/{config[md_tpr]} \
                     -n {input.ndx} \
                     -select 'group "r_935_&_OH" plus group "r_18_&_OH"' \
                     -oall {output} -tu ns
        """


rule plot_t24_y935_all_heatmaps:
    input:
        rules.make_t24_y935_xvg.output,
    output:
        "results/{folder}/y935_dists/Y935_dist_heatmap.png",
    params:
        n_runs=N_RUNS,
        title="Y935\u2013K18Ac",
        vmin=2,
        vmax=10,
    script:
        "../scripts/plot_single_heatmap.py"


rule plot_t24_y935_ar_kde:
    input:
        rules.make_t24_y935_xvg.output,
    output:
        "results/{folder}/y935_dists/Y935_dist_kde.png",
    params:
        xmin=2,
        xmax=10,
        xlabel="Distance (Å)",
    script:
        "../scripts/plot_kde.py"


rule make_t24_y935_xvg_clip_10ns:
    input:
        xtc="runs/{folder}/combined_clip_10ns.xtc",
        ndx="runs/{folder}/y935_dist.ndx",
    output:
        "results/{folder}/y935_dists/data/clip_y935_oh_k18ac.xvg",
    params:
        prefix="runs/{folder}",
    shell:
        """
        gmx distance -f {input.xtc} -s {params.prefix}/{config[md_tpr]} \
                     -n {input.ndx} \
                     -select 'group "r_935_&_OH" plus group "r_18_&_OH"' \
                     -oall {output} -tu ns
        """


rule plot_t24_y935_kde_clip_10ns:
    input:
        rules.make_t24_y935_xvg_clip_10ns.output,
    output:
        "results/{folder}/y935_dists/Y935_dist_kde_clip_10ns.png",
    params:
        xmin=2,
        xmax=10,
        xlabel="Distance (Å)",
    script:
        "../scripts/plot_kde.py"
