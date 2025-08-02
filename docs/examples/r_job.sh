#!/bin/bash
#SBATCH --job-name=r_analysis
#SBATCH --output=r_analysis_%j.out
#SBATCH --error=r_analysis_%j.err
#SBATCH --time=01:30:00
#SBATCH --mem=6G
#SBATCH --cpus-per-task=4
#SBATCH --partition=compute

# Load required modules
module purge
module load r/4.1.0
module load gcc/9.3.0

# Set environment variables
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Print job information
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $SLURM_NODELIST"
echo "CPUs: $SLURM_CPUS_PER_TASK"
echo "Memory: $SLURM_MEM_PER_NODE"
echo "Start time: $(date)"

# Create scratch directory for temporary files
export TMPDIR=/scratch/$USER/tmp
mkdir -p $TMPDIR

# Your R analysis code here
Rscript << 'EOF'
# Load required libraries
library(ggplot2)
library(dplyr)
library(parallel)

# Set number of cores for parallel processing
num_cores <- 4
options(mc.cores = num_cores)

cat("Starting R analysis...\n")

# Generate sample data
cat("Generating sample data...\n")
set.seed(123)
n_samples <- 100000

data <- data.frame(
  x = rnorm(n_samples, mean = 0, sd = 1),
  y = rnorm(n_samples, mean = 2, sd = 1.5),
  group = sample(c("A", "B", "C"), n_samples, replace = TRUE)
)

# Perform statistical analysis
cat("Performing statistical analysis...\n")

# Summary statistics
summary_stats <- data %>%
  group_by(group) %>%
  summarise(
    mean_x = mean(x),
    sd_x = sd(x),
    mean_y = mean(y),
    sd_y = sd(y),
    n = n()
  )

print(summary_stats)

# Linear regression
cat("Fitting linear regression model...\n")
model <- lm(y ~ x + group, data = data)
summary_model <- summary(model)
print(summary_model)

# Create visualizations
cat("Creating visualizations...\n")

# Scatter plot
p1 <- ggplot(data, aes(x = x, y = y, color = group)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Scatter Plot with Regression Line",
       x = "X Variable",
       y = "Y Variable") +
  theme_minimal() +
  theme(legend.position = "bottom")

# Histogram
p2 <- ggplot(data, aes(x = x, fill = group)) +
  geom_histogram(alpha = 0.7, bins = 30, position = "identity") +
  labs(title = "Distribution of X Variable by Group",
       x = "X Variable",
       y = "Count") +
  theme_minimal() +
  theme(legend.position = "bottom")

# Box plot
p3 <- ggplot(data, aes(x = group, y = y, fill = group)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Box Plot of Y Variable by Group",
       x = "Group",
       y = "Y Variable") +
  theme_minimal() +
  theme(legend.position = "none")

# Save plots
ggsave("scatter_plot.png", p1, width = 10, height = 6, dpi = 300)
ggsave("histogram.png", p2, width = 10, height = 6, dpi = 300)
ggsave("box_plot.png", p3, width = 8, height = 6, dpi = 300)

cat("Plots saved: scatter_plot.png, histogram.png, box_plot.png\n")

# Save results
cat("Saving results...\n")

# Save summary statistics
write.csv(summary_stats, "summary_statistics.csv", row.names = FALSE)

# Save model coefficients
coef_df <- data.frame(
  variable = names(coef(model)),
  coefficient = coef(model),
  std_error = summary_model$coefficients[, "Std. Error"],
  t_value = summary_model$coefficients[, "t value"],
  p_value = summary_model$coefficients[, "Pr(>|t|)"]
)
write.csv(coef_df, "model_coefficients.csv", row.names = FALSE)

# Save model summary
sink("model_summary.txt")
print(summary_model)
sink()

cat("Results saved to CSV files and model_summary.txt\n")
cat("R analysis completed successfully!\n")
EOF

# Clean up temporary files
rm -rf $TMPDIR

# Print completion information
echo "End time: $(date)"
echo "Job completed successfully!" 