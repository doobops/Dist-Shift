# Install packages -------------------------------------------------------------
rm(list=ls())

packages <- c("devtools", "Rcpp", "ggplot2", "gganimate", "gapminder", "dplyr", 
              "installr", "animation", "tweenr", "ggforce", "plotly", "tidyr", 
              "MASS", "bindata", "gifski", "png", "transformr", "grid", "magick",
              "gridExtra", "knitr", "shiny")
lapply(packages, require, character.only = TRUE)

source("D:/GitHub/Animated-SLO/Inputs.R")

# Assign colors for graphing subgroups -----------------------------------------
Both <- "#ff7373"
ELL <- "#ffad5a" 
SPED <- "#4f9da6"
None <- "#280c64" 

mycolors <- c( "None" = None, "ELL" = ELL, "SPED" = SPED, "Both" = Both)

# Create default theme ---------------------------------------------------------    
mytheme <-
  theme(
    panel.background = element_rect(fill = "white"), 
    axis.line = element_line(),
    legend.key=element_blank()
  )

# Create regression ------------------------------------------------------------

reganim <- ggplot(train, aes(x = pretest, y = posttest, color = subgroup)) + 
  
  # Layers 1 - 4
  geom_point(data = train[train$subgroup=="None", ], alpha = .75) +
  geom_point(data = train[train$subgroup=="ELL", ], alpha = .75) +
  geom_point(data = train[train$subgroup=="SPED", ], alpha = .75) +
  geom_point(data = train[train$subgroup=="Both", ], alpha = .75) + 
  
  # Layers 5 - 8
  geom_abline(intercept = yint.none, slope = beta, color = None, size = 1) +
  geom_abline(intercept = yint.ell, slope = beta, color = ELL, size = 1) +
  geom_abline(intercept = yint.sped, slope = beta, color = SPED, size = 1) +
  geom_abline(intercept = yint.both, slope = beta, color = Both, size = 1) +
  
  scale_colour_manual(breaks = c("None", "ELL", "SPED", "Both"), values = mycolors) + 
  
  labs(x = "Prior Achievement Score",
       y = "End of Year Score",
       color = "Student Profile") + 
  
  mytheme +
  
  transition_layers() + 
  
  # transition_layers(layer_length = .5, transition_length = .25,
  #                   from_blank = TRUE, keep_layers = c(rep(Inf, 8)))  +
  
  # enter_appear() + 
  # enter_appear() + 
  # enter_appear() + 
  # enter_appear() + 
  enter_fly(x_loc=train$x_loc, y_loc=train$y_loc)
  
 animate(reganim)

# Plot goals -------------------------------------------------------------------

# Fitted values for None and Both
yhat_none <- test$yhat[test$subgroup == "None"]
yhat_both <- test$yhat[test$subgroup == "Both"]

# Grob for pretest annotation
txt_pretest <- textGrob(paste("Pretest=", pre), gp = gpar(fontsize = 9, fontface = "bold"))

# Grobs for goal annotations  
txt_yhat_none <- textGrob(paste("Goal=", yhat_none), gp = gpar(fontsize = 9, fontface = "bold"))
txt_yhat_both <- textGrob(paste("Goal=", yhat_both), gp = gpar(fontsize = 9, fontface = "bold"))  

# Animate
predanim <- 
  ggplot(train, aes(x = pretest, y = posttest)) +
  
  geom_point(alpha = .5, aes(color = subgroup)) + 
  
  # Best fit lines
  geom_abline(intercept = yint.none, slope = beta, size = 1, alpha = .75, color = None) +
  geom_abline(intercept = yint.ell, slope = beta, size = 1, alpha = .75, color = ELL) +
  geom_abline(intercept = yint.sped, slope = beta, size = 1, alpha = .75, color = SPED) +
  geom_abline(intercept = yint.both, slope = beta, size = 1, alpha = .75, color = Both) +
  
  # Pretest setup
  annotation_custom(txt_pretest, xmin = pre, xmax = pre, ymin = min(train$posttest), ymax = min(train$posttest)) +
  geom_point(data = test[test$subgroup == "None", ], aes(x = pretest, y = -Inf), color="black") +
  geom_segment(aes(x = pre, xend = pre, y = -Inf, yend = yhat_none), color = "black", linetype = 2, size=.75) + 
  
  # Subgroup None
  geom_segment(aes(x = pre, xend = -Inf, y = yhat_none, yend = yhat_none), color = "black", linetype = 2, size = .75, arrow=arrow(length=unit(0.4,"cm"))) +
  geom_point(data = test[test$subgroup == "None", ], aes(x = -Inf, y = yhat_none), color="black") +
  annotation_custom(txt_yhat_none, xmin = min(train$pretest) + .5, xmax = min(train$pretest) + .5, ymin = yhat_none + .5, ymax = yhat_none + .5 ) + 
  
  # Subgroup Both
  geom_segment(aes(x = pre, xend = -Inf, y = yhat_both, yend = yhat_both), color = "black", linetype = 2, size = .75, arrow=arrow(length=unit(0.4,"cm"))) +
  geom_point(data = test[test$subgroup == "None", ], aes(x = -Inf, y = yhat_both), color="black") +
  annotation_custom(txt_yhat_both, xmin = min(train$pretest) + .5, xmax = min(train$pretest) + .5, ymin = yhat_both + .5, ymax = yhat_both + .5) +    
  
  # Transitions
  transition_layers(layer_length = .5, 
                    transition_length = .25,
                    from_blank = TRUE, 
                    keep_layers = c(4, Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf
                    )) +
  
  enter_fade() + 
  exit_fade() + 
  enter_fade() +
  enter_fade() +
  enter_fade() +
  enter_fade() +
  enter_fly
  
  
  # Format
  scale_colour_manual(breaks = c("None", "ELL", "SPED", "Both"), values = mycolors) + 
  
  labs(x = "Prior Achievement Score",
       y = "End of Year Score",
       color = "Student Profile") + 
  
  mytheme

animate(predanim)


ggplot(mtcars, aes(factor(gear), mpg)) +
  geom_boxplot() +
  transition_states(gear, 2, 1)+enter_fade() + enter_grow() +
  exit_fly(x_loc = 7, y_loc = 40) + exit_recolour(fill = 'forestgreen')