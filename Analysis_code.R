#Load libraries
library(rcompanion)
library(ggplot2)
library(scales)

#load data and set seed
df <- read.csv("input.csv")
set.seed(123)

#Effect size for the difference in sample characteristics between healthcare centers:

#Specify continuous and grouping variables
scales   <- c("age", "dx_age", "bmi")
centre   <- "source"
cat_vars <- c("gender", "asd_fhx", "epilepsy", "sleep_disorder")

#Prepare an empty results data frame for Krustkal-Wallis test results
results_char1 <- data.frame(scale        = character(),
                            H_value      = numeric(),
                            df           = integer(),
                            p_value      = numeric(),
                            eps_sq       = numeric(),
                            CI_lower_95  = numeric(),
                            CI_upper_95  = numeric(),
                            stringsAsFactors = FALSE
)

#Loop over continuous variables
for (y in scales){
  
  sub        <- df[, c(y, centre)]
  names(sub) <- c("y", "g")
  sub        <- na.omit(sub)
  sub$y      <- as.numeric(sub$y)
  sub$g      <- factor(sub$g,levels = c("al_subtain","al_hussein","baghdad"))
  
  #Kruskal–Wallis test
  kw <- kruskal.test(y ~ g, data = sub)
  
  #ε² effect size:
  eps <- epsilonSquared(x           = sub$y,
                        g           = sub$g,
                        ci          = TRUE,
                        conf.level  = 0.95,
                        type        = "bca",
                        R           = 10000
  )
  
  #Plot
  p <- ggplot(sub, aes(x = g, y = y)) +
        geom_jitter(width = 0.2, alpha = 0.6) +
        stat_summary(fun = median, geom = "crossbar", width = 0.5,
                     color = "blue", size = 0.6) +
        labs( 
          title    = paste0("Scatter of ", y, " by ", g),
          subtitle = paste0("ε² = ", round(eps, 3)),
          x        = g,
          y        = y
        ) +
        theme_minimal(base_size = 14)
  print(p)
  
  #Append results
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

#Prepare an empty results data frame for chi-square test results
results_char2 <- data.frame(variable     = character(),
                            chisq_stat   = numeric(),
                            df           = integer(),
                            p_value      = numeric(),
                            cramers_V    = numeric(),
                            CI_lower_95  = numeric(),
                            CI_upper_95  = numeric(),
                            stringsAsFactors = FALSE
)

#Loop over categorical variables
for (v in cat_vars) {
  
  sub <- df[, c(v, centre)]
  names(sub) <- c("y", "g")
  sub <- na.omit(sub)
  sub$y <- factor(sub$y)
  sub$g <- factor(sub$g, levels = c("al_subtain","al_hussein","baghdad"))
  
  tbl <- table(sub$y, sub$g)
  
  #Chi-square test
  chi <- chisq.test(tbl, correct = FALSE)
  
  #Cramér’s V effect size
  cv <- cramerV(tbl, 
                ci    = TRUE,
                conf  = 0.95,
                type  = "bca",
                R     = 10000
  )

  #Plot
  p <- ggplot(sub, aes(x = y, fill = g)) +
        geom_bar(position = "fill", width = 0.7, alpha = 0.7) +
        scale_y_continuous(labels = percent_format()) +
        labs(
          title    = sprintf("Distribution of %s by %s", v, centre),
          x        = v,
          y        = "Proportion"
        ) +
        theme_minimal(base_size = 14)
  print(p)
  
  #Append results
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

#Print results
print(results_char1)
print(results_char2)

#Effect size for potential factors associated with BMI:

#Specify continuous and grouping variables
y_var          <- "bmi"
binary_groups  <- c("chronic_condition","family_hx","excessive_screentime", "resperidone")
multi_groups   <- c("calorie", "daytime_activity", "family_lifestyle")

#Prepare an empty results frame for Man-Whitney U test results
results_binary <- data.frame(group       = character(),
                             U_stat      = numeric(),
                             p_value     = numeric(),
                             r_value  =    numeric(),
                             CI_lower_95 = numeric(),
                             CI_upper_95 = numeric(),
                             stringsAsFactors = FALSE
)

#Loop over each binary grouping variable
for (g in binary_groups) {
  
  sub <- df[, c(y_var, g)]
  names(sub) <- c("y","g")
  sub <- na.omit(sub)
  sub$g <- factor(sub$g, levels = c("No","Yes"))
  
  #Mann–Whitney test
  wt <- wilcox.test(y ~ g, data = sub, exact = FALSE)
  
  #R-values effect size
  r <- -1*wilcoxonR(x          = sub$y,
                    g          = sub$g,
                    ci         = TRUE,
                    conf.level = 0.95,
                    type       = "bca",
                    R          = 10000
  )
  r[c(2, 3)] <- r[c(3, 2)]

  #Plot
  p <- ggplot(sub, aes(x = g, y = y)) +
        geom_jitter(width = 0.2, alpha = 0.6) +
        stat_summary(fun = median, geom = "crossbar", width = 0.5,
                     color = "blue", size = 0.6) +
        labs(
          title    = paste0("Scatter of ", y_var, " by ", g),
          subtitle = paste0("r = ", round(r, 3)),
          x        = g,
          y        = y_var
        ) +
        theme_minimal(base_size = 14)
  print(p)
  
  #Append to results
  results_binary <- rbind(results_binary,
                          data.frame(group       = g,
                                     U_stat      = as.numeric(wt$statistic),
                                     p_value     = wt$p.value,
                                     r_value     = r,
                                     stringsAsFactors = FALSE
    )
  )
}

#Prepare an empty results data frame for Krustkal-Wallis test results
results_multi <- data.frame(group        = character(),
                            H_value      = numeric(),
                            df           = integer(),
                            p_value      = numeric(),
                            eps_sq       = numeric(),
                            CI_lower_95  = numeric(),
                            CI_upper_95  = numeric(),
                            stringsAsFactors = FALSE
)

#Loop over non-binary grouping variables
for (g in multi_groups) {
  
  sub        <- df[, c(y_var, g)]
  names(sub) <- c("y", "g")
  sub        <- na.omit(sub)
  sub$y      <- as.numeric(sub$y)
  sub$g      <- factor(sub$g,levels = c("Low","Moderate","High"))
  
  #Kruskal–Wallis test
  kw <- kruskal.test(y ~ g, data = sub)
  
  #ε² effect size:
  eps <- epsilonSquared(x           = sub$y,
                        g           = sub$g,
                        ci          = TRUE,
                        conf.level  = 0.95,
                        type        = "bca",
                        R           = 10000
  )
  
  #Plot
  p <- ggplot(sub, aes(x = g, y = y)) +
        geom_jitter(width = 0.2, alpha = 0.6) +
        stat_summary(fun = median, geom = "crossbar", width = 0.5,
                     color = "blue", size = 0.6) +
        labs(
          title    = paste0("Scatter of ", y_var, " by ", g),
          subtitle = paste0("ε² = ", round(eps, 3)),
          x        = g,
          y        = y_var
        ) +
        theme_minimal(base_size = 14)
  print(p)
  
  #Append results
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

#Print results
print(results_binary)
print(results_multi)
