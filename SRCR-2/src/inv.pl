:- op( 900,xfy,'::' ).

evolucao(T) :- findall(Invariante, +T :: Invariante, Lista),
               insercao(T),
               teste(Lista).

involucao(T) :- findall(Invariante, -T :: Invariante, Lista),
              remocao(T),
              teste(Lista).

insercao(T) :- assert(T).
insercao(T) :- retract(T),!,fail.


atualizacao(Tantigo, Tnovo) :- Tantigo,
                               findall(Invariante, +Tnovo :: Invariante, Lista),
                               findall(Invariantes, update(Tantigo) :: Invariantes, ListaUpd),
                               insercao(Tantigo,Tnovo),
                               teste(ListaUpd),
                               teste(Lista).

insercao(Tantigo,Tnovo) :- assert(Tnovo),retract(Tantigo).
insercao(Tantigo,Tnovo) :- assert(Tantigo),retract(Tnovo),!,fail.

teste([]).
teste([I|T]) :- I,teste(T).

remocao(T) :- retract(T).
remocao(T) :- assert(T), !, fail.

comprimento([], 0).
comprimento([_|T], R) :- comprimento(T, R1), R is R1 + 1.