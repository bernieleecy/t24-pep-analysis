# For n980 distances, this is an optional input
# Data already aggregated, no input functions required


rule make_t24_n980_ndx:
    input:
        "runs/{folder}/md_1.tpr",
    output:
        n980_ndx="runs/{folder}/n980_dist.ndx",
    params:
        grp_1="r 980 & a ND2",
        grp_2="r 18 & a OH",
    shell:
        """
        mkdir -p results/{wildcards.folder}/n980_dists/data
        echo -e "{params.grp_1} \n{params.grp_2} \nq" |
        gmx make_ndx -f {input} -o {output}
        """


rule make_t24_n980_xvg:
    input:
        xtc="runs/{folder}/combined.xtc",
        ndx="runs/{folder}/n980_dist.ndx",
    output:
        "results/{folder}/n980_dists/data/n980_nd2_k18ac.xvg",
    params:
        prefix="runs/{folder}",
    shell:
        """
        gmx distance -f {input.xtc} -s {params.prefix}/{config[md_tpr]} \
                     -n {input.ndx} \
                     -select 'group "r_980_&_ND2" plus group "r_18_&_OH"' \
                     -oall {output} -tu ns
        """


rule plot_t24_n980_all_heatmaps:
    input:
        rules.make_t24_n980_xvg.output,
    output:
        "results/{folder}/n980_dists/N980_dist_heatmap.png",
    params:
        n_runs=N_RUNS,
        title="N980\u2013K18Ac",
        vmin=2,
        vmax=10,
    script:
        "../scripts/plot_single_heatmap.py"


rule plot_t24_n980_ar_kde:
    input:
        rules.make_t24_n980_xvg.output,
    output:
        "results/{folder}/n980_dists/N980_dist_kde.png",
    params:
        xmin=2,
        xmax=10,
        xlabel="Distance (Å)",
        dist_on=True,
    script:
        "../scripts/plot_kde.py"


rule make_t24_n980_xvg_clip_10ns:
    input:
        xtc="runs/{folder}/combined_clip_10ns.xtc",
        ndx="runs/{folder}/n980_dist.ndx",
    output:
        "results/{folder}/n980_dists/data/clip_n980_nd2_k18ac.xvg",
    params:
        prefix="runs/{folder}",
    shell:
        """
        gmx distance -f {input.xtc} -s {params.prefix}/{config[md_tpr]} \
                     -n {input.ndx} \
                     -select 'group "r_980_&_ND2" plus group "r_18_&_OH"' \
                     -oall {output} -tu ns
        """


rule plot_t24_n980_kde_clip_10ns:
    input:
        rules.make_t24_n980_xvg_clip_10ns.output,
    output:
        "results/{folder}/n980_dists/N980_dist_kde_clip_10ns.png",
    params:
        xmin=2,
        xmax=10,
        xlabel="Distance (Å)",
        dist_on=True,
    script:
        "../scripts/plot_kde.py"
