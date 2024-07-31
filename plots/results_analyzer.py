from results_loader import ResultsLoader
from results_plotter import ResultsPlotter

class ResultsAnalyzer:
  def __init__(self, directories, benchmark_app, annotation, experiments):
    self.loader = ResultsLoader(directories)
    self.plotter = None
    self.directories = directories
    self.benchmark_app = benchmark_app
    self.annotation = annotation
    self.experiments_filter = experiments.split(',')

  # ad-hoc approach to get the variants and verify all the experiments have the same ones
  def fetch_experiment_variants(self):
    variants = []
    for experiment, experiment_data in self.plotter.data_avg.items():
      if variants != []:
        assert (variants == list(experiment_data.keys())), \
          "Experiments have different variants - not able to create a grouped plot"
      else:
        variants = list(experiment_data.keys())
    return self.plotter.fix_variants_order(variants)

  def analyze(self, error_bar, metric_type):
    (data_avg, data_std) = self.loader.load_data(self.experiments_filter)
    self.plotter = ResultsPlotter(data_avg, data_std, error_bar, metric_type, self.benchmark_app)

  def plot_results(self, axes, plt_type, xaxis, plot_idx=None):
    if not self.plotter:
      print("Plotter is not instatiated. Please analyze the results first.")
      exit()
    if axes is None:
      print("Axes for the figure are not provided")
      exit()

    if plt_type == "bar":
      if xaxis == "threads":
        for experiment, experiment_data in self.plotter.data_avg.items():
          std_error_data = self.plotter.data_std[experiment]
          if plot_idx is None:
            self.plotter.plot_bars_threads(axes, experiment, experiment_data, std_error_data, self.annotation)
          else:
            self.plotter.plot_bars_threads(axes[plot_idx], experiment, experiment_data, std_error_data, self.annotation)
            plot_idx += 1
      elif xaxis == "experiments":
        if plot_idx is None:
          self.plotter.plot_bars_experiments(axes, self.annotation)
        else:
          self.plotter.plot_bars_experiments(axes[plot_idx], self.annotation)
          plot_idx += 1
    elif plt_type == "line":
      if xaxis == "threads":
        for experiment, experiment_data in self.plotter.data_avg.items():
          std_error_data = self.plotter.data_std[experiment]
          if plot_idx is None:
            self.plotter.plot_lines_threads(axes, experiment, experiment_data, std_error_data, None, self.annotation)
          else:
            self.plotter.plot_lines_threads(axes[plot_idx], experiment, experiment_data, std_error_data, None, self.annotation)
            plot_idx += 1
      elif xaxis == "experiments":
        print("Line plot type does not support experiments as x-axis.")
        exit()

    return plot_idx