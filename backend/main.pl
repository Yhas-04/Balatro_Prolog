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

meta(1, 100).
meta(2, 250).
meta(3, 500).

max_descartes(3).

:- dynamic estado/3.
estado(1, 0, 0).

avaliar_mao(Cartas, Mao, Pontos) :-
    pegar_faces(Cartas, Faces),
    pegar_naipes(Cartas, Naipes),
    pegar_valores(Faces, Valores),
    escolher_mao(Faces, Naipes, Valores, Mao),
    pontuacao_base(Mao, Base),
    length(Cartas, Quantidade),
    Bonus is (Quantidade - 1) * 5,
    Pontos is Base + Bonus.


escolher_mao(Faces, Naipes, _, royal_flush) :-
    tem_flush(Naipes),
    member(10, Faces),
    member(valete, Faces),
    member(dama, Faces),
    member(rei, Faces),
    member(as, Faces), !.

      member(as, Faces), !.

escolher_mao(_, Naipes, Valores, straight_flush) :-
    tem_flush(Naipes),
    tem_sequencia(Valores), !.

escolher_mao(Faces, _, _, quadra) :-
    tem_repetidas(Faces, 4), !.

escolher_mao(Faces, _, _, full_house) :-
    tem_full_house(Faces), !.

escolher_mao(_, Naipes, _, flush) :-
    tem_flush(Naipes), !.

escolher_mao(_, _, Valores, sequencia) :-
    tem_sequencia(Valores), !.

escolher_mao(Faces, _, _, trinca) :-
    tem_repetidas(Faces, 3), !.

escolher_mao(Faces, _, _, dois_pares) :-
    tem_dois_pares(Faces), !.

escolher_mao(Faces, _, _, par) :-
    tem_repetidas(Faces, 2), !.

escolher_mao(_, _, _, carta_alta).

contar(_, [], 0).
contar(Item, [Item | Resto], Quantidade) :-
    contar(Item, Resto, Parcial),
    Quantidade is Parcial + 1.
contar(Item, [Outro | Resto], Quantidade) :-
    Item \= Outro,
    contar(Item, Resto, Quantidade).

    tem_repetidas(Lista, Minimo) :-
    member(Item, Lista),
    contar(Item, Lista, Quantidade),
    Quantidade >= Minimo.


tem_flush(Naipes) :-
    member(Naipe, Naipes),
    contar(Naipe, Naipes, Quantidade),
    Quantidade = 5.

tem_dois_pares(Faces) :-
    findall(Face, (member(Face, Faces), contar(Face, Faces, Qtd), Qtd >= 2), Pares),
    sort(Pares, ParesSemRepetir),
    length(ParesSemRepetir, Quantidade),
    Quantidade >= 2.

tem_full_house(Faces) :-
    member(Trinca, Faces),
    contar(Trinca, Faces, QtdTrinca),
    QtdTrinca >= 3,
    member(Par, Faces),
    Trinca \= Par,
    contar(Par, Faces, QtdPar),
    QtdPar >= 2.

tem_sequencia(Valores) :-
    sort(Valores, SemRepetir),
    tratar_as_baixo(SemRepetir, ValoresParaTeste),
    tem_cinco_seguidos(ValoresParaTeste).

tratar_as_baixo(Valores, [1 | Valores]) :-
    member(14, Valores), !.
tratar_as_baixo(Valores, Valores).


tem_cinco_seguidos(Valores) :-
    append(_, [A, B, C, D, E | _], Valores),
    B is A + 1,
    C is B + 1,
    D is C + 1,
    E is D + 1.
