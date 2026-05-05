naipe(copas).
naipe(espadas).
naipe(ouros).
naipe(paus).

face(2).  face(3).  face(4).  face(5).  face(6).  face(7).  face(8).
face(9).  face(10). face(valete). face(dama). face(rei). face(as).

valor(2, 2).
valor(3, 3).
valor(4, 4).
valor(5, 5).
valor(6, 6).
valor(7, 7).
valor(8, 8).
valor(9, 9).
valor(10, 10).
valor(valete, 11).
valor(dama, 12).
valor(rei, 13).
valor(as, 14).

pontuacao_base(royal_flush, 800).
pontuacao_base(straight_flush, 500).
pontuacao_base(quadra, 400).
pontuacao_base(full_house, 300).
pontuacao_base(flush, 200).
pontuacao_base(sequencia, 150).
pontuacao_base(trinca, 100).
pontuacao_base(dois_pares, 60).
pontuacao_base(par, 30).
pontuacao_base(carta_alta, 10).
