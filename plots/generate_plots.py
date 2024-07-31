import argparse
import matplotlib.pyplot as plt
import os
from results_analyzer import ResultsAnalyzer

app_name_map = {
  "pytorch"               :   "PyTorch",
  "openvino"              :   "OpenVINO",
  "memcached"             :   "Memcached",
  "redis"                 :   "Redis",
  "blender"               :   "Blender",
  "lighttpd"              :   "Lighttpd",
  "sqlite"                :   "SQLite",
  "sqlite-tmpfs"          :   "SQLite - tmpfs",
  "tensorflow"            :   "TensorFlow",
  "python"                :   "Python",
  "candle"                :   "Candle",
  "bild"                  :   "Go bild app",
  "java_image"            :   "Java app"
}

def main():
  parser = argparse.ArgumentParser(description='Produce plots for Gramine-TDX.')
  parser.add_argument('--directories', '-d', nargs='+', required=True, \
                      help='List of directories containing CSV files. For multiple directories for the results of one app, \
                      use the \":\" separator and the plot will be based on the average of these results.')
  parser.add_argument('--apps', '-a', nargs='+', required=True, \
                      help='List of the applications. 1-1 matching with the directories is required.')
  parser.add_argument('--annotation', '-n', default=None, choices=['absolute', 'overhead'], \
                      help='Annotation type')
  parser.add_argument('--experiments', '-e', nargs='+', required=True, default=['default'], 
                      help='List of comma spearated experiments for each app (case sensitive). 1-1 matching with directories and apps is required.')
  parser.add_argument('--xaxis', '-x', default='threads', choices=['threads', 'experiments'],
                      help='Choose x-axis type. Note that "experiments" type is only available for single-threaded results.')
  parser.add_argument('--metric_types', '-m', nargs='+', required=True, default=None, choices=['LIB', 'HIB'], 
                      help='List of metric types. Choose from "LIB" (Lower Is Better) and "HIB" (Higher Is Better). \
                      1-1 matching with directories and apps is required.')
  parser.add_argument('--plt_type', '-p', default='bar', choices=['bar', 'line'],
                      help='Choose plot type. By default the bar plot type is chosen.')
  parser.add_argument('--legend_loc', '-l', default="upper center",
                      help='Choose the location of the legend. Note that in case of a group plot, it applies to the first subplot.')
  parser.add_argument('--output_dir', '-o', default='plots', \
                      help='Directory to place the plot(s).')
  parser.add_argument('--title', '-t', default='my_plot', \
                      help='Plot title.')
  parser.add_argument('--error_bar', action='store_true', help="Add standard error bars in the plots.")
  args = parser.parse_args()

  # Sanity checks
  if len(args.directories) != len(args.apps):
    print("Error: Number of directories must be equal to the number of apps (match 1-1).")
    exit()
  
  if args.experiments and len(args.experiments) != len(args.apps):
    print("Error: Number of experiment lists must be equal to the number of apps (match 1-1).")
    exit(0)

  # Create the output directory, if it does not exit
  script_dir = os.path.dirname(os.path.realpath(__file__))
  out_dir = os.path.join(script_dir, args.output_dir)
  if not os.path.exists(out_dir):
    os.mkdir(out_dir)

  # Calculcate the amount of subplots
  if args.xaxis == "experiments":
    subplots = len(args.apps) # if experiments are on the x-axis, each app has its own subplot
  elif args.xaxis == "threads":
    subplots = ",".join(args.experiments).count(',') + 1 # merge the experiments and count the ',' + 1

  # Create the appropriate subplot set
  _, axes = plt.subplots(1, subplots, figsize=(8 * subplots, 3))

  plot_idx = 0
  for directories, app, experiments, metric_type in zip(args.directories, args.apps, args.experiments, args.metric_types):
    print(f"Generating {args.title} plot for {app} with {args.xaxis} as x-axis", end =" ")
    print(f"-- used experiments: {experiments}, annotation type: {args.annotation}, error bars: {args.error_bar}")
    analyzer = ResultsAnalyzer(directories, app_name_map[app.lower()], args.annotation, experiments)
    analyzer.analyze(args.error_bar, metric_type)
    if subplots > 1:
      plot_idx = analyzer.plot_results(axes, args.plt_type, args.xaxis, plot_idx)
    else:
      _ = analyzer.plot_results(axes, args.plt_type, args.xaxis)
    # verify that all the plots have the same variants so that they can have a unified legend
    variants = analyzer.fetch_experiment_variants()
  
  # using the last version of the variants is sufficient as all the plots should share the same variants
  cols = 1
  if args.legend_loc is None: # set the default setup that works for all the plots
    cols = len(variants)
  
  if subplots > 1:
    axes[0].legend(labels=variants, ncols=cols, loc=args.legend_loc, fontsize="small")
  else:
    axes.legend(labels=variants, ncols=cols, loc=args.legend_loc, fontsize="small")
  
  plt.tight_layout()
  plt.savefig(f"{out_dir}/{args.title}.pdf", dpi=300, format='pdf', bbox_inches='tight')
  plt.savefig(f"{out_dir}/{args.title}.png", dpi=300, format='png', bbox_inches='tight')

if __name__ == "__main__":
  main()