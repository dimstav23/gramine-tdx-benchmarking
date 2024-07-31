import sys
import matplotlib.pyplot as plt
import numpy as np

import matplotlib
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

import seaborn as sb
palette = sb.color_palette("pastel")
colour = palette
hatch = ["", "//", "..", "", "++", "", "", "//", "..", "", "++", ""]
markers = ['o', 's', '+', 'x', 'D', '*', 'o', 's', '+', 'x', 'D', '*']

variants_plot_sequence = [
  "Native",
  "Native w/ socat",
  "Normal VM",
  "Normal VM w/ socat",
  "Intel TDX VM",
  "Intel TDX VM w/ socat",
  "Gramine-SGX",
  "Gramine-VM",
  "Gramine-TDX",
]

class ResultsPlotter:
  def __init__(self, data_avg, data_std, error_bar, metric_type, benchmark_app):
    self.data_avg = data_avg
    self.data_std = data_std
    self.error_bar = error_bar
    self.metric_type = metric_type
    self.benchmark_app = benchmark_app

  def fix_variants_order(self, variants):
    # variants is the original list of variants in random order
    # variants_plot_sequence is the sequence we want for the bars

    # get the existing labeled variants and put them in the desired order
    labeled_variants = [variant for variant in variants_plot_sequence if variant in variants]

    return labeled_variants

  def annotate_directional_arrow(self, axes):
    FONT_SIZE = 9
    xytext=(20, 150)
    if self.metric_type == "LIB":
      text = "Lower is better ↓"
    elif self.metric_type == "HIB":
      text = "Higher is better ↑"
    else:
      print("No metric type is provided. Possible values: LIB (lower is better) or HIB (higher is better).")
      exit(0)

    axes.annotate(
      text,
      xycoords="axes points",
      xy=(0, 0),
      xytext=xytext,
      fontsize=FONT_SIZE,
      color="navy",
      weight="bold",
    )

  def annotate_abs_values(self, axes, bars, data, y_lim):
    fontsize = 6
    text_y1 = []
    for bar, value in zip(bars, data):
      t = axes.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02 * y_lim, f'{value:.3f}', 
                  in_layout=True, ha='center', va='bottom', rotation='vertical', fontsize=fontsize)
      text_y1.append(t.get_window_extent().transformed(axes.transData.inverted()).y1)
    # return the top position of the annotation to increase the ylimit if needed
    return max(text_y1)

  def annotate_overhead(self, axes, bars, baseline_data, data, y_lim):
    fontsize = 6
    text_y1 = []
    for idx, (bar, value) in enumerate(zip(bars, data)):
      t = axes.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02 * y_lim, f'{value/baseline_data[idx]:.2f}', 
                in_layout=True, ha='center', va='bottom', rotation='vertical', fontsize=fontsize)
      text_y1.append(t.get_window_extent().transformed(axes.transData.inverted()).y1)
    # return the top position of the annotation to increase the ylimit if needed
    return max(text_y1)

  def plot_thread_bar(self, axes, experiment, experiment_data, std_error_data):
    variants = list(experiment_data.keys()) # bars per data point
    x_axis_labels = list(experiment_data[variants[0]].index) # x-axis data points
    
    bar_area_percentage = 0.8 # bar width to cover 80% of the dedicated space
    width = float(bar_area_percentage / len(variants)) # width of each bar
    x = np.arange(len(x_axis_labels)) # number of xaxis ticks
    x_spacing = np.linspace(-bar_area_percentage/2 + width/2, bar_area_percentage/2 - width/2, num=len(variants)) # position of each x-tick

    # sort the variants for the bar plots
    sorted_variants = self.fix_variants_order(variants)

    # plot the bars
    bars = []
    for i, variant in enumerate(sorted_variants):
      bar_data = experiment_data[variant].to_numpy().flatten() # values to be plotted
      error_data = std_error_data[variant].to_numpy().flatten() # standard error bar values
      if self.error_bar is True:
        bars.append(axes.bar(x + x_spacing[i], bar_data, yerr=error_data, width=width, label=variant,
                        color=colour[i], hatch=hatch[i], edgecolor='black'))
      else:
        bars.append(axes.bar(x + x_spacing[i], bar_data, width=width, label=variant,
                        color=colour[i], hatch=hatch[i], edgecolor='black'))
    # if we have a single thread value, do not print xlabel
    if len(x_axis_labels) == 1:
      axes.set_xticks([])
    else:
      axes.set_xlabel(experiment_data[variant].keys().name)
      axes.set_xticks(range(0, len(x_axis_labels)), x_axis_labels)
    
    axes.set_ylabel(experiment_data[variant].keys()[0])
    if experiment == "default":
      if self.benchmark_app == "PyTorch": # custom fix for pytorch title
        axes.set_title(self.benchmark_app + " - AlexNet")
      else:
        axes.set_title(self.benchmark_app)
    elif self.benchmark_app == "Memcached" and experiment == "TOTAL": # custom fix for Memcached TOTAL experiment
      axes.set_title(self.benchmark_app)
    else:
      if experiment.lower() == "bert": # custom fix for BERT capitalization in the title
        experiment = "BERT Large"
      axes.set_title(self.benchmark_app + " - " + experiment)
    # return the bars for the annotation
    return bars

  def annotate_thread_bar(self, axes, annotation, experiment_data, bars):
    variants = list(experiment_data.keys()) # number of bars per data point
    sorted_variants = self.fix_variants_order(variants)

    _, y_lim = axes.get_ylim() # get the y_lim to adjust the annotation height
    y_limits = [y_lim] # create a list of the text y_limits to update the ylim of the plot if needed
    for i, variant in enumerate(sorted_variants):
      annot_data = experiment_data[variant].to_numpy().flatten() # retrieve the values
      if annotation == "absolute":
        y_limits.append(self.annotate_abs_values(axes, bars[i], annot_data, y_lim))
      elif annotation == "overhead": # overhead annotation to the native value
        baseline_variant = "Native"
        if baseline_variant not in experiment_data.keys(): # check if native variant is provided
          sys.exit("Overhead annotation specified but \"native\" variant is not provided.")
        baseline_data = experiment_data[baseline_variant].to_numpy().flatten() # baseline values
        y_limits.append(self.annotate_overhead(axes, bars[i], baseline_data, annot_data, y_lim))
    axes.set_ylim(0, max(y_limits) + 0.04 * max(y_limits)) # increase the y_lim in case the text goes beyond the border
    return

  # data here is the whole dataset
  def plot_experiment_bar(self, axes, data_avg, data_std):
    # x-axis the name of the experiments
    x_axis_labels = list(data_avg.keys())
    # take the variants of the first experiment
    variants = list(data_avg[x_axis_labels[0]].keys())
    # force all the experiments to have the same variants
    for _, experiment_data in data_avg.items():
      for variant in experiment_data.keys():
        if variant not in variants:
          print("All the experiments should have the same variants")
          return
    sorted_variants = self.fix_variants_order(variants)

    bar_area_percentage = 0.8 # bar width to cover 80% of the dedicated space
    width = float(bar_area_percentage / len(sorted_variants)) # width of each bar
    x = np.arange(len(x_axis_labels)) # number of xaxis ticks
    x_spacing = np.linspace(-bar_area_percentage/2 + width/2, bar_area_percentage/2 - width/2, num=len(sorted_variants)) # position of each x-tick

    # plot the bars
    bars = []
    for i, variant in enumerate(sorted_variants):
      bar_data = []
      error_data = []
      for _, experiment_data in data_avg.items():
        bar_data.append(experiment_data[variant].iloc[0][experiment_data[variant].columns[0]])
      for _, std_error_data in data_std.items():
        error_data.append(std_error_data[variant].iloc[0][std_error_data[variant].columns[0]])
      if self.error_bar is True:
        bars.append(axes.bar(x + x_spacing[i], bar_data, yerr=error_data, width=width, label=variant,
                        color = colour[i], hatch=hatch[i], edgecolor='black'))
      else:
        bars.append(axes.bar(x + x_spacing[i], bar_data, width=width, label=variant,
                        color = colour[i], hatch=hatch[i], edgecolor='black'))

    # trick for memcached experiment titles
    if self.benchmark_app == "Memcached":
      x_axis_labels = [experiment.split('-')[0] for experiment in x_axis_labels]

    axes.set_xlabel('Workload')
    axes.set_xticks(range(0, len(x_axis_labels)), x_axis_labels)
    
    axes.set_ylabel(experiment_data[variant].keys()[0])
    axes.set_title(self.benchmark_app)

    # return the bars for the annotation
    return bars

  # data here is the whole dataset
  def annotate_experiment_bar(self, axes, annotation, data, bars):
    x_axis_labels = list(data.keys())
    variants = list(data[x_axis_labels[0]].keys())
    sorted_variants = self.fix_variants_order(variants)

    _, y_lim = axes.get_ylim() # get the y_lim to adjust the annotation height
    y_limits = [y_lim] # create a list of the text y_limits to update the ylim of the plot if needed
    for i, variant in enumerate(sorted_variants):
      annot_data = []
      for _, experiment_data in data.items():
        annot_data.append(experiment_data[variant].iloc[0][experiment_data[variant].columns[0]])
      if annotation == "absolute":
        y_limits.append(self.annotate_abs_values(axes, bars[i], annot_data, y_lim))
      elif annotation == "overhead": # overhead annotation to the native value
        baseline_variant = "Native"
        if baseline_variant not in experiment_data.keys(): # check if native variant is provided
          sys.exit("Overhead annotation specified but \"native\" variant is not provided.")
        baseline_data = []
        for _, experiment_data in data.items():
          baseline_data.append(experiment_data[baseline_variant].iloc[0][experiment_data[baseline_variant].columns[0]]) # baseline values
        y_limits.append(self.annotate_overhead(axes, bars[i], baseline_data, annot_data, y_lim))
    axes.set_ylim(0, max(y_limits) + 0.04 * max(y_limits)) # increase the y_lim in case the text goes beyond the border
    return

  def plot_bars_threads(self, axes, experiment, experiment_data, std_error_data, annotation=None):
    bars = self.plot_thread_bar(axes, experiment, experiment_data, std_error_data)
    if annotation != None:
      self.annotate_thread_bar(axes, annotation, experiment_data, bars)
    self.annotate_directional_arrow(axes)

  def plot_bars_experiments(self, axes, annotation=None):
    bars = self.plot_experiment_bar(axes, self.data_avg, self.data_std)
    if annotation != None:
      self.annotate_experiment_bar(axes, annotation, self.data_avg, bars)
    self.annotate_directional_arrow(axes)

  def plot_thread_line(self, axes, experiment, experiment_data, std_error_data):
    variants = list(experiment_data.keys()) # bars per data point
    x_axis_labels = list(experiment_data[variants[0]].index) # x-axis data points
    x = np.arange(len(x_axis_labels)) # number of xaxis ticks

    # sort the variants for the bar plots
    sorted_variants = self.fix_variants_order(variants)

    # plot the bars
    lines = []
    for i, variant in enumerate(sorted_variants):
      line_data = experiment_data[variant].to_numpy().flatten() # values to be plotted
      # error_data = std_error_data[variant].to_numpy().flatten() # standard error bar values
      # lines.append(axes.plot(x, line_data, yerr=error_data, label=variant,
      #                 color = colour[i], marker=markers[i], markersize=4))
      lines.append(axes.plot(x, line_data, label=variant,
                      color = colour[i], marker=markers[i], markersize=4))
    # if we have a single thread value, do not print xlabel
    if len(x_axis_labels) == 1:
      axes.set_xticks([])
    else:
      axes.set_xlabel(experiment_data[variants[0]].columns.name)
      axes.set_xticks(range(0, len(x_axis_labels)), x_axis_labels)

    axes.set_ylabel(experiment_data[variant].keys()[0])
    if experiment == "default":
      axes.set_title(self.benchmark_app)
    else:
      axes.set_title(self.benchmark_app + " - " + experiment)
    # return the lines
    return lines

  def plot_lines_threads(self, axes, experiment, experiment_data, std_error_data, annotation=None):
    lines = self.plot_thread_line(axes, experiment, experiment_data, std_error_data)