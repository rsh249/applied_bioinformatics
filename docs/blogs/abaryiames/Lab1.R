data= c(1.1,1.5,1.2,0.7,1.6,0.2,1.1, 1.1, 1.2, 1.7,0.2, 0.7, 0.8, 0.9)
mean = (sum(data) / length(data))
sd = sqrt(sum((data - mean)^2 / (length(data)-1)))

x <- ggplot(data = census) +
  geom_histogram(stat="identity", aes(x = State, y = Transit)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
