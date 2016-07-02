tp_lexer <- scan(); tp_lexer
tp_parser <- scan(); tp_parser
tp_total <- apply(rbind(tp_lexer, tp_parser), 2, sum); tp_total
p <- 1:length(tp_total)
sp_lexer <- tp_lexer[1] / tp_lexer; sp_lexer
sp_parser <- tp_parser[1] / tp_parser; sp_parser
sp_total <- tp_total[1] / tp_total; sp_total
ep_lexer <- sp_lexer / p; ep_lexer
ep_parser <- sp_parser / p; ep_parser
ep_total <- sp_total / p; ep_total
plot(p, tp_lexer, type="l", main="Лексикален анализатор", sub="Време спрямо брой нишки", xlab="p", ylab="Tp")
plot(p, tp_parser, type="l", main="Парсър", sub="Време спрямо брой нишки", xlab="p", ylab="Tp")
plot(p, tp_total, type="l", main="Общо", sub="Време спрямо брой нишки", xlab="p", ylab="Tp")
plot(p, sp_lexer, type="l", main="Лексикален анализатор", sub="Ускорение спрямо брой нишки", xlab="p", ylab="Sp")
plot(p, sp_parser, type="l", main="Парсър", sub="Ускорение спрямо брой нишки", xlab="p", ylab="Sp")
plot(p, sp_total, type="l", main="Общо", sub="Ускорение спрямо брой нишки", xlab="p", ylab="Sp")
plot(p, ep_lexer, type="l", main="Лексикален анализатор", sub="Ефективност спрямо брой нишки", xlab="p", ylab="Ep")
plot(p, ep_parser, type="l", main="Парсър", sub="Ефективност спрямо брой нишки", xlab="p", ylab="Ep")
plot(p, ep_total, type="l", main="Общо", sub="Ефективност спрямо брой нишки", xlab="p", ylab="Ep")