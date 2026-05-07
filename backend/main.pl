:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_cors)).

:- set_setting(http:cors, [*]).
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
get_estado(Round, Pontuacao, Descartes) :-
    estado(Round, Pontuacao, Descartes).
set_estado(Round, Pontuacao, Descartes) :-
    retractall(estado(_, _, _)),
    assertz(estado(Round, Pontuacao, Descartes)).
avaliar_mao(Cartas, Mao, Pontos) :-
    pegar_faces(Cartas, Faces),
    pegar_naipes(Cartas, Naipes),
    pegar_valores(Faces, Valores),
    escolher_mao(Faces, Naipes, Valores, Mao),
    pontuacao_base(Mao, Base),
    length(Cartas, Quantidade),
    Bonus is (Quantidade - 1) * 5,
    Pontos is Base + Bonus.
pegar_faces([], []).
pegar_faces([_-Face | Resto], [Face | Faces]) :-
    pegar_faces(Resto, Faces).
pegar_naipes([], []).
pegar_naipes([Naipe-_ | Resto], [Naipe | Naipes]) :-
    pegar_naipes(Resto, Naipes).
pegar_valores([], []).
pegar_valores([Face | Resto], [Valor | Valores]) :-
    valor(Face, Valor),
    pegar_valores(Resto, Valores).
escolher_mao(Faces, Naipes, _, royal_flush) :-
    tem_flush(Naipes),
    member(10, Faces),
    member(valete, Faces),
    member(dama, Faces),
    member(rei, Faces),
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
    Quantidade >= 5.
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

:- http_handler('/api/avaliar', handler_avaliar, [methods([post, options])]).
:- http_handler('/api/estado', handler_estado, [methods([get, options])]).
:- http_handler('/api/descartar', handler_descartar, [methods([post, options])]).
:- http_handler('/api/novo_round', handler_novo_round, [methods([post, options])]).
:- http_handler('/api/resetar', handler_resetar, [methods([post, options])]).
start_server(Porta) :-
    http_server(http_dispatch, [port(Porta)]).
responder(Request, Dict) :-
    format("Access-Control-Allow-Origin: *~n"),
    format("Access-Control-Allow-Methods: GET, POST, OPTIONS~n"),
    format("Access-Control-Allow-Headers: Content-Type~n"),
    (   member(method(options), Request)
    ->  format("Content-type: application/json~n~n"),
        json_write_dict(current_output, _{ok:true}, [])
    ;   reply_json_dict(Dict)
    ).
handler_avaliar(Request) :-
    pedido_options(Request), !,
    responder(Request, _{}).
handler_avaliar(Request) :-
    http_read_json_dict(Request, Body),
    cartas_json_para_prolog(Body.cartas, Cartas),
    avaliar_mao(Cartas, Mao, PontosRodada),
    get_estado(Round, PontuacaoAtual, Descartes),
    NovaPontuacao is PontuacaoAtual + PontosRodada,
    set_estado(Round, NovaPontuacao, Descartes),
    meta(Round, Meta),
    venceu_meta(NovaPontuacao, Meta, Venceu),
    atom_string(Mao, MaoTexto),
    responder(Request, _{
        mao: MaoTexto,
        pontos_rodada: PontosRodada,
        pontuacao: NovaPontuacao,
        meta: Meta,
        round: Round,
        venceu: Venceu
    }).
handler_descartar(Request) :-
    pedido_options(Request), !,
    responder(Request, _{}).
handler_descartar(Request) :-
    get_estado(Round, Pontuacao, Descartes),
    max_descartes(Maximo),
    (   Descartes >= Maximo
    ->  responder(Request, _{erro:"Sem descartes restantes", descartes_usados:Descartes, max:Maximo})
    ;   NovosDescartes is Descartes + 1,
        Restantes is Maximo - NovosDescartes,
        set_estado(Round, Pontuacao, NovosDescartes),
        responder(Request, _{ok:true, descartes_usados:NovosDescartes, descartes_restantes:Restantes})
    ).
handler_estado(Request) :-
    get_estado(Round, Pontuacao, Descartes),
    meta(Round, Meta),
    max_descartes(Maximo),
    Faltam is max(0, Meta - Pontuacao),
    DescartesRestantes is Maximo - Descartes,
    responder(Request, _{
        round: Round,
        pontuacao: Pontuacao,
        meta: Meta,
        faltam: Faltam,
        descartes_restantes: DescartesRestantes
    }).
handler_novo_round(Request) :-
    pedido_options(Request), !,
    responder(Request, _{}).
handler_novo_round(Request) :-
    get_estado(RoundAtual, _, _),
    ProximoRound is RoundAtual + 1,
    (   meta(ProximoRound, NovaMeta)
    ->  set_estado(ProximoRound, 0, 0),
        responder(Request, _{ok:true, round:ProximoRound, meta:NovaMeta})
    ;   responder(Request, _{fim:true, mensagem:"Voce venceu o jogo!"})
    ).
handler_resetar(Request) :-
    pedido_options(Request), !,
    responder(Request, _{}).
handler_resetar(Request) :-
    set_estado(1, 0, 0),
    meta(1, Meta),
    responder(Request, _{ok:true, round:1, meta:Meta}).
pedido_options(Request) :-
    member(method(options), Request).
venceu_meta(Pontuacao, Meta, true) :-
    Pontuacao >= Meta, !.
venceu_meta(_, _, false).
cartas_json_para_prolog([], []).
cartas_json_para_prolog([CartaJson | Resto], [Naipe-Face | Cartas]) :-
    atom_string(Naipe, CartaJson.naipe),
    face_json_para_prolog(CartaJson.face, Face),
    cartas_json_para_prolog(Resto, Cartas).
face_json_para_prolog(Numero, Numero) :-
    number(Numero), !.
face_json_para_prolog(Texto, Numero) :-
    number_string(Numero, Texto), !.
face_json_para_prolog(Texto, Face) :-
    atom_string(Face, Texto).

:- initialization(main).
main :-
    start_server(8080),
    thread_get_message(_).