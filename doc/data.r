tp_lexer <- c(10290.781728, 9688.815649, 9893.138364, 9656.216076, 9845.111727, 9656.521882, 9688.695327, 9669.590845, 9866.888565, 9694.934786, 9649.756515, 9845.757591, 9767.112981, 9915.506494, 9682.353990); tp_lexer
tp_parser <- c(17945.963957, 17136.798029, 17283.407232, 17224.419706, 17241.839613, 17554.116244, 17211.345622, 17846.559005, 17771.716818, 17925.423752, 17342.307615, 17781.824748, 17403.409597, 18158.555230, 17838.187585); tp_parser
tp_total <- apply(rbind(tp_lexer, tp_parser), 2, sum); tp_total
p <- 1:length(tp_total)
sp_lexer <- tp_lexer[1] / tp_lexer; sp_lexer
sp_parser <- tp_parser[1] / tp_parser; sp_parser
sp_total <- tp_total[1] / tp_total; sp_total
ep_lexer <- sp_lexer / p; ep_lexer
ep_parser <- sp_parser / p; ep_parser
ep_total <- sp_total / p; ep_total
plot(p, tp_lexer, type="l", main="Lexical analyser", sub="Execution time against thread count", xlab="p", ylab="Tp")
plot(p, tp_parser, type="l", main="Parser", sub="Execution time against thread count", xlab="p", ylab="Tp")
plot(p, tp_total, type="l", main="Total", sub="Execution time against thread count", xlab="p", ylab="Tp")
plot(p, sp_lexer, type="l", main="Lexical analyser", sub="Speedup against thread count", xlab="p", ylab="Sp")
plot(p, sp_parser, type="l", main="Parser", sub="Speedup against thread count", xlab="p", ylab="Sp")
plot(p, sp_total, type="l", main="Total", sub="Speedup against thread count", xlab="p", ylab="Sp")
plot(p, ep_lexer, type="l", main="Lexical analyser", sub="Efficiency against thread count", xlab="p", ylab="Ep")
plot(p, ep_parser, type="l", main="Parser", sub="Efficiency against thread count", xlab="p", ylab="Ep")
plot(p, ep_total, type="l", main="Total", sub="Efficiency against thread count", xlab="p", ylab="Ep")