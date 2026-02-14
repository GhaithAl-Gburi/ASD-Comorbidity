# Settings

## Clear working environment

rm(list = ls())

## Set a random seed
set.seed(123)

## Required packages
packages <- c("rcompanion","ggplot2","scales")

for (package in packages) {
  
  if (!requireNamespace(package, quietly = TRUE))
    install.packages(package)
  
  suppressPackageStartupMessages(library(package, character.only = TRUE))
  
}

## Import and inspect data attributes

df <- read.csv("ASD_comobidity_dataset.csv")

attributes(df)[names(attributes(df)) != "row.names"]

# Difference in sample characteristics across healthcare centers

## Define Variables and result objects

#Specify continuous and grouping variables
scales   <- c("age", "dx_age", "bmi")
centre   <- "source"
cat_vars <- c("gender", "asd_fhx", "epilepsy", "sleep_disorder")

#Prepare an empty data frame for Kruskal-Wallis test results
results_char1 <- data.frame(scale        = character(),
                            H_value      = numeric(),
                            df           = integer(),
                            p_value      = numeric(),
                            eps_sq       = numeric(),
                            CI_lower_95  = numeric(),
                            CI_upper_95  = numeric(),
                            stringsAsFactors = FALSE
)

#Prepare an empty data frame for chi-square test results
results_char2 <- data.frame(variable     = character(),
                            chisq_stat   = numeric(),
                            df           = integer(),
                            p_value      = numeric(),
                            cramers_V    = numeric(),
                            CI_lower_95  = numeric(),
                            CI_upper_95  = numeric(),
                            stringsAsFactors = FALSE
)

## Epsilon-squared effect size for continuous characteristics

#Loop over continuous variables
for (y in scales){
  
  # Subset and clean the data
  sub        <- df[, c(y, centre)]
  names(sub) <- c("y", "g")
  sub        <- na.omit(sub)
  sub$y      <- as.numeric(sub$y)
  sub$g      <- factor(sub$g,levels = c("al_subtain","al_hussein","baghdad"))
  
  # Kruskal–Wallis test
  kw <- kruskal.test(y ~ g, data = sub)
  
  # Epsilon-squared effect size:
  eps <- epsilonSquared(x           = sub$y,
                        g           = sub$g,
                        ci          = TRUE,
                        conf.level  = 0.95,
                        type        = "bca",
                        R           = 10000
  )
  
  # Jitter and median crossbar plot
  p <- ggplot(sub, aes(x = g, y = y)) +
    geom_jitter(width = 0.2, alpha = 0.6) +
    stat_summary(fun = median, 
                 geom = "crossbar", 
                 width = 0.5,
                 color = "blue", 
                 linewidth = 0.6
    ) +
    labs(title    = paste0("Scatter of ", y, " by ", centre),
         subtitle = paste0("Epsilon-squared = ", round(eps, 3)),
         x        = centre,
         y        = y
    ) +
    theme_minimal(base_size = 14)
  print(p)
  
  # Append results
  results_char1 <- rbind(results_char1,
                         data.frame(scale        = y,
                                    H_value      = as.numeric(kw$statistic),
                                    df           = kw$parameter,
                                    p_value      = kw$p.value,
                                    eps_sq       = eps,
                                    stringsAsFactors = FALSE
                         )
  )
}

# Print results
print(results_char1)

## Cramer's V effect size for categorical characteristics

# Loop over categorical variables
for (v in cat_vars) {
  
  # Subset and clean the data
  sub <- df[, c(v, centre)]
  names(sub) <- c("y", "g")
  sub <- na.omit(sub)
  sub$y <- factor(sub$y)
  sub$g <- factor(sub$g, levels = c("al_subtain","al_hussein","baghdad"))
  
  tbl <- table(sub$y, sub$g)
  
  # Chi-square test
  chi <- chisq.test(tbl, correct = FALSE)
  
  # Cramer’s V effect size
  cv <- cramerV(tbl, 
                ci    = TRUE,
                conf  = 0.95,
                type  = "bca",
                R     = 10000
  )
  
  # Stacked bar chart
  p <- ggplot(sub, aes(x = y, fill = g)) +
    geom_bar(position = "fill", width = 0.7, alpha = 0.7) +
    scale_y_continuous(labels = percent_format()) +
    labs(title    = sprintf("Distribution of %s by %s", v, centre),
         x        = v,
         y        = "Proportion"
    ) +
    theme_minimal(base_size = 14)
  print(p)
  
  # Append results
  results_char2 <- rbind(results_char2,
                         data.frame(variable     = v,
                                    chisq_stat   = as.numeric(chi$statistic),
                                    df           = as.integer(chi$parameter),
                                    p_value      = chi$p.value,
                                    cramers_V    = cv,
                                    stringsAsFactors = FALSE
                         )
  )
}

# Print results
print(results_char2)

# Difference in BMI across potentially-associated factors

## Define Variables and result objects

#Specify continuous and grouping variables
y_var          <- "bmi"
binary_groups  <- c("chronic_condition","family_hx","excessive_screentime", "resperidone")
multi_groups   <- c("calorie", "daytime_activity", "family_lifestyle")

#Prepare an empty data frame for Man-Whitney U test results
results_binary <- data.frame(group       = character(),
                             U_stat      = numeric(),
                             p_value     = numeric(),
                             r_value  =    numeric(),
                             CI_lower_95 = numeric(),
                             CI_upper_95 = numeric(),
                             stringsAsFactors = FALSE
)

#Prepare an empty data frame for Kruskal-Wallis test results
results_multi <- data.frame(group        = character(),
                            H_value      = numeric(),
                            df           = integer(),
                            p_value      = numeric(),
                            eps_sq       = numeric(),
                            CI_lower_95  = numeric(),
                            CI_upper_95  = numeric(),
                            stringsAsFactors = FALSE
)

## Wilixicon R effect size for binary grouping variables

# Loop over binary grouping variables
for (g in binary_groups) {
  
  # Subset and clean the data
  sub <- df[, c(y_var, g)]
  names(sub) <- c("y","g")
  sub <- na.omit(sub)
  sub$g <- factor(sub$g, levels = c("No","Yes"))
  
  # Mann–Whitney test
  wt <- wilcox.test(y ~ g, data = sub, exact = FALSE)
  
  # R-values effect size
  r <- -1*wilcoxonR(x          = sub$y,
                    g          = sub$g,
                    ci         = TRUE,
                    conf.level = 0.95,
                    type       = "bca",
                    R          = 10000
  )
  r[c(2, 3)] <- r[c(3, 2)]
  
  # Jitter and median crossbar plot
  p <- ggplot(sub, aes(x = g, y = y)) +
    geom_jitter(width = 0.2, alpha = 0.6) +
    stat_summary(fun = median, 
                 geom = "crossbar",
                 width = 0.5,
                 color = "blue", 
                 linewidth = 0.6
    ) +
    labs(title    = paste0("Scatter of ", y_var, " by ", g),
         subtitle = paste0("r = ", round(r, 3)),
         x        = g,
         y        = y_var
    ) +
    theme_minimal(base_size = 14)
  print(p)
  
  #Append result
  results_binary <- rbind(results_binary,
                          data.frame(group       = g,
                                     U_stat      = as.numeric(wt$statistic),
                                     p_value     = wt$p.value,
                                     r_value     = r,
                                     stringsAsFactors = FALSE
                          )
  )
}

# Print results
print(results_binary)

## Epsilon-squared effect size for multi-level grouping variables

#Loop over non-binary grouping variables
for (g in multi_groups) {
  
  # Subset and clean the data
  sub        <- df[, c(y_var, g)]
  names(sub) <- c("y", "g")
  sub        <- na.omit(sub)
  sub$y      <- as.numeric(sub$y)
  sub$g      <- factor(sub$g,levels = c("Low","Moderate","High"))
  
  # Kruskal–Wallis test
  kw <- kruskal.test(y ~ g, data = sub)
  
  # Epsilon-squared effect size:
  eps <- epsilonSquared(x           = sub$y,
                        g           = sub$g,
                        ci          = TRUE,
                        conf.level  = 0.95,
                        type        = "bca",
                        R           = 10000
  )
  
  # Jitter and median crossbar plot
  p <- ggplot(sub, aes(x = g, y = y)) +
    geom_jitter(width = 0.2, alpha = 0.6) +
    stat_summary(fun = median, 
                 geom = "crossbar", 
                 width = 0.5,
                 color = "blue", 
                 linewidth = 0.6
    ) +
    labs(title    = paste0("Scatter of ", y_var, " by ", g),
         subtitle = paste0("Epsilon-squared = ", round(eps, 3)),
         x        = g,
         y        = y_var
    ) +
    theme_minimal(base_size = 14)
  print(p)
  
  # Append results
  results_multi <- rbind(results_multi,
                         data.frame(group        = g,
                                    H_value      = as.numeric(kw$statistic),
                                    df           = kw$parameter,
                                    p_value      = kw$p.value,
                                    eps_sq       = eps,
                                    stringsAsFactors = FALSE
                         )
  )
}

# Print results
print(results_multi)
