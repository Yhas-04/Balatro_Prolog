O jogador forma mãos de poker e tenta bater a meta de pontos de cada round.

---

## Como rodar após o git clone

```bash
docker compose up --build
```

Acesse: **http://localhost:3000**

---

---

## O jogo em Prolog

O arquivo `game.pl` tem três partes:

**Fatos**

```prolog
naipe(copas). naipe(espadas). naipe(ouros). naipe(paus).

pontuacao_base(royal_flush, 800).
pontuacao_base(par, 30).

meta(1, 100).
meta(2, 250).
meta(3, 500).
```

**Estado dinâmico** — o round atual, pontuação e descartes usados ficam salvos e são atualizados a cada jogada:

```prolog
:- dynamic estado/3.
estado(1, 0, 0).  % round, pontuação, descartes
```

**Regras**

```prolog
escolher_mao(Faces, Naipes, _, royal_flush) :-
    tem_flush(Naipes), member(as, Faces), member(rei, Faces), ...

escolher_mao(Faces, _, _, par) :-
    tem_repetidas(Faces, 2), !.

escolher_mao(_, _, _, carta_alta).
```

---

## Docker e Nginx

**Docker** sobe dois containers: o backend com SWI-Prolog na porta `8080` e o frontend com Nginx na porta `3000`.

**Nginx** faz duas coisas:
- Serve os arquivos estáticos do frontend (HTML, CSS)
- Encaminha as requisições `/api/*` para o backend Prolog
