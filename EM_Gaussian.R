EMGaussianMixture <- function(data, K, n_init) {
  n <- nrow(data)
  d <- ncol(data)
  
  best_log_likelihood <- -Inf
  best_model <- list()
  
  for (init in 1:n_init) {
    # Initialisation
    pi <- runif(K)
    pi <- pi / sum(pi)
    mu <- matrix(rnorm(K*d), nrow=K, ncol=d)
    sigma <- array(apply(array(rnorm(K*d*d), dim=c(d,d,K)), 3, function(mat) {
      mat <- matrix(mat, ncol=d)
      return(t(mat) %*% mat)
    }), dim=c(d,d,K))
    
    log_likelihood <- 0
    log_likelihood_prev <- -Inf
    iter <- 0
    log_likelihood_history <- numeric()
    
    # EM steps
    while (!is.na(log_likelihood) && !is.nan(log_likelihood) && abs(log_likelihood - log_likelihood_prev) > 1e-06) {
      # E step
      gamma <- matrix(0, nrow=n, ncol=K)
      for (k in 1:K) {
        gamma[,k] <- pi[k] * dmvnorm(data, mean=mu[k,], sigma=sigma[,,k])
      }
      gamma <- gamma / rowSums(gamma)
      
      # M step
      Nk <- colSums(gamma)
      for (k in 1:K) {
        mu[k,] <- colSums(gamma[,k] * data) / Nk[k]
        xc <- sweep(data, 2, mu[k,])
        sigma[,,k] <- (t(xc) %*% (xc * gamma[,k])) / Nk[k]
        pi[k] <- Nk[k] / n
      }
      
      # Log likelihood
      log_likelihood_prev <- log_likelihood
      log_likelihood <- sum(log(rowSums(gamma)))
      log_likelihood_history <- c(log_likelihood_history, log_likelihood)
      
      iter <- iter + 1
    }
    
    if (!is.na(log_likelihood) && !is.nan(log_likelihood) && !is.na(best_log_likelihood) && !is.nan(best_log_likelihood) && log_likelihood > best_log_likelihood) {
      best_log_likelihood <- log_likelihood
      best_model <- list(pi=pi, mu=mu, sigma=sigma, log_likelihood=log_likelihood_history,  gamma=gamma ,assignment=max.col(gamma))
    }
  }
  
  return(best_model)
}

library(mvtnorm)
data = as.matrix(iris[,-5])
result <- EMGaussianMixture(data = data, K= 3, n_init=20)


#Experimentation de l'algorithme 
#Paramètre du premier cluster
mu1 <- c(2, 3)
sigma1 <- matrix(c(1, 0.5, 0.5, 2), ncol = 2)

#Paramètres du deuxième cluster
mu2 <- c(-2, -1)
sigma2 <- matrix(c(4, 2, 2, 3), nrow=2, ncol=2, byrow=TRUE)

# Nombre d'observations à générer
n <- 100
#Proportions de composantes
pi <- c(0.4, 0.6)

#Générer des données à partir d'un mélange Gaussien
data <- matrix(rnorm(80, mean = mu1, sd = sigma1), ncol = 2)
data <- rbind(data, matrix(rnorm(120, mean = mu2, sd = sigma2), ncol = 2))
result <- EMGaussianMixture(data = data, K= 2, n_init=20)





