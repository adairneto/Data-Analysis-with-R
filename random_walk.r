set.seed(1234567)

step <- c(1,-1)
n <- 1000
s <- numeric(n)
s[1] <- 0 

for (i in 2:n) {
  s[i] <- s[i - 1] + sample(step, 1)
}

plot(s, type = "l")

