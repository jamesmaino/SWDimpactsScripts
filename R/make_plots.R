library(tidyverse)

d = read_csv("../simout/SimulationSummary.csv") %>% 
  mutate(area_km2 = 0.01 * area) %>% # area in ha
  mutate(areasd_km2 = 0.01 * areasd) %>% 
  mutate(traps_per_km2 = traps_per_cell/9^2) # cell size is 9 x 9 km

ggplot(d, aes(traps_per_cell, area)) + 
  geom_line() +
  scale_y_log10()
  
ggplot(d, aes(traps_per_km2, area_km2)) + 
  geom_line() + 
  geom_ribbon(aes(ymin = max(0, area_km2 - areasd_km2), 
                  ymax = area_km2 + areasd_km2), alpha=0.1) +
  scale_y_log10() +
  theme_classic() +
  ylab(expression("area invaded at detection (km"^2*")")) +
  xlab(expression("surveillance effort (trap number per km"^2*")"))
ggsave("area_invaded_vs_surveillance_effort.png")

