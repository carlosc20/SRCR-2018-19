
?- consult(['si.pl','inv.pl']).

nuloInterdito(nuloInterdito).

nulo(nulo).
nulo([H|T]).
nulo(nuloInterdito).

nuloNaoImpreciso(nulo).
nuloNaoImpreciso(nuloInterdito).

:- dynamic excecao/1.
:- dynamic '-'/1.

%Extensões do SI
%e predicado conjunção
e(T1,T2):-si(T1,verdadeiro),si(T2,verdadeiro).
-e(T1,T2):- si(T1,falso).
-e(T1,T2):- si(T2,falso).


%ou predicado conjunção
ou(T1,T2):- si(T1,verdadeiro).
ou(T1,T2):- si(T2,verdadeiro).
-ou(T1,T2):- si(T1,falso),si(T2,falso).


%xor
xor(T1,T2):- si(T1,verdadeiro),si(T2,falso).
xor(T1,T2):- si(T1,falso),si(T2,verdadeiro).
-xor(T1,T2):- si(T1,verdadeiro),si(T2,verdadeiro).
-xor(T1,T2):- si(T1,falso),si(T2,falso).


% UTENTE--------------------------------------------------------------------------------------------
% utente(#IdUt, Nome, Idade, Morada)
:- dynamic utente/4.
-utente(IdUt, Nome, Idade, Morada) :- nao(utente(IdUt, Nome, Idade, Morada)),
                                      nao(excecao(utente(IdUt, Nome, Idade, Morada))).

%% Invariantes de Utente
%% A idade de um utente só pode ser nula ou um inteiro positivo
+utente(IdUt, Nome, Idade, Morada) :: (
                                        findall(IdUt, utente(IdUt, _, _, _), L1),
                                        comprimento(L1, 1), % Não pode haver repetidos
                                        si(
                                          ou( 
                                            e( integer(Idade), Idade >= 0), 
                                            nulo(Idade)
                                          ),
                                          verdadeiro
                                        ) % Idade é um inteiro positivo ou é um nulo.
                                      ).
+utente(IdUt, Nome, Idade, Morada) :: nao(nulo(IdUt)).

-utente(IdUt, Nome, Idade, Morada) :: nao(nuloInterdito(Idade)).
-utente(IdUt, Nome, Idade, Morada) :: nao(nuloInterdito(Nome)).
-utente(IdUt, Nome, Idade, Morada) :: nao(nuloInterdito(Morada)).

%% Uma entrada de utente so pode ser removida se:
%%%  -não existir utentes
%%%  -existirem mais do que uma entrada com o mesmo id 
-utente(IdUt, Nome, Idade, Morada) :: (
                                        findall(IdCuid, cuidado(IdCuid,_,IdUt,_,_,_),L1),
                                        comprimento(L1, 0)
                                      ).

%% Invariante de atualização
%% Termo antigo, teste no novo
% update(Tantigo) :: Invariante.
update(utente(IdUt,nuloInterdito, _, _))  :: utente(IdUt, nuloInterdito, _, _).
update(utente(IdUt, _, nuloInterdito, _)) :: utente(IdUt, _, nuloInterdito, _).
update(utente(IdUt, _, _, nuloInterdito)) :: utente(IdUt, _, _, nuloInterdito).
update(utente(IdUt, _, _, _)) :: utente(IdUt, _, _, _).

%% Exceções de utente
excecao(utente(IdUt, Nome, Idade, Morada)) :- 
      utente(IdUt, ListaDeNome, ListaDeIdade, ListaDeMorada),
      si(ou(contem(Nome, ListaDeNome), nuloNaoImpreciso(ListaDeNome)), verdadeiro),
      si(ou(contem(Idade, ListaDeIdade), nuloNaoImpreciso(ListaDeIdade)), verdadeiro),
      si(ou(contem(Morada, ListaDeMorada), nuloNaoImpreciso(ListaDeMorada)), verdadeiro).

% PRESTADOR------------------------------------------------------------------------------------------
% prestador(#IdPrest, Nome, Especialidade, Instituicao)
:- dynamic prestador/4.

-prestador(IdPrest, Nome, Especialidade, Instituicao) :- nao(prestador(IdPrest, Nome, Especialidade, Instituicao)),
                                                         nao(excecao(prestador(IdPrest, Nome, Especialidade, Instituicao))).

%% Invariantes de Prestador
+prestador(IdPrest, Nome, Especialidade, Instituicao) :: (
                                                            findall(IdUt, prestador(IdPrest, _, _, _), L1),
                                                            comprimento(L1, 1) % Não pode haver repetidos
                                                         ).

+prestador(IdPrest, Nome, Especialidade, Instituicao) :: nao(nulo(IdPrest)).
  
-prestador(IdPrest, Nome, Especialidade, Instituicao) :: (
                                                            findall(IdCuid, cuidado(IdCuid,_,_,IdPrest,_,_),L1),
                                                            comprimento(L1, 0)
                                                         ).

-prestador(IdPrest, Nome, Especialidade, Instituicao) :: nao(nuloInterdito(Nome)).
-prestador(IdPrest, Nome, Especialidade, Instituicao) :: nao(nuloInterdito(Especialidade)).
-prestador(IdPrest, Nome, Especialidade, Instituicao) :: nao(nuloInterdito(Instituicao)).

update(prestador(IdPrest, nuloInterdito, _, _))  :: prestador(IdPrest, nuloInterdito,_,_).
update(prestador(IdPrest, _, nuloInterdito, _))  :: prestador(IdPrest, _,nuloInterdito,_).
update(prestador(IdPrest, _, _, nuloInterdito)) :: prestador(IdPrest, _,_,nuloInterdito).
update(prestador(IdPrest, _, _, _)) :: prestador(IdPrest, _,_,_).


 
%% Excecoes de Prestador 
excecao(prestador(IdPrest, Nome, Especialidade, Instituicao)) :- prestador(IdPrest, ListaDeNome, ListaDeEspecialidade, ListaDeInstituicao),
                                                                 si(ou(contem(Nome, ListaDeNome), nuloNaoImpreciso(ListaDeNome)),verdadeiro),
                                                                 si(ou(contem(Especialidade, ListaDeEspecialidade), nuloNaoImpreciso(ListaDeEspecialidade)),verdadeiro),
                                                                 si(ou(contem(Instituicao, ListaDeInstituicao), nuloNaoImpreciso(ListaDeInstituicao)),verdadeiro).


% CUIDADO--------------------------------------------------------------------------------------------
% cuidado(#IdUt, #IdPrest, Descricao, Custo)
:- dynamic cuidado/6.

-cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo) :- nao(cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo)),
                                                           nao(excecao(cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo))).
%% Invariantes de Cuidados 

% O prestador e o utente tem de existir para poder haver cuidado se não for nulo
+cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo) ::si(ou(
                                                               (utente(IdUt,_,_,_), prestador(IdPrest,_,_,_)),
                                                               ou(
                                                                  (nulo(IdCuid), prestador(IdPrest,_,_,_)),
                                                                  ou(
                                                                     (utente(IdUt,_,_,_), nulo(IdPrest)),
                                                                     (nulo(IdUt), nulo(IdPrest))
                                                                  )
                                                               )
                                                            ),
                                                            verdadeiro
                                                         ).

% Não pode haver cuidados repetidos.
+cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo) :: (
                                                            findall(IdCuid, cuidado(IdCuid, _, _, _, _, _), L1),
                                                            comprimento(L1, 1) % Não pode haver repetidos
                                                         ).

% Um prestador não pode ter mais do que 8 cuidados por dia 
+cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo) :: (
                                                            findall(Data, cuidado(_, Data, _, _, _, _), L1),
                                                            comprimento(L1, S), S=<8
                                                         ).

-cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo) :: nao(nuloInterdito(Data)).
-cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo) :: nao(nuloInterdito(IdUt)).
-cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo) :: nao(nuloInterdito(IdPrest)).
-cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo) :: nao(nuloInterdito(Descricao)).
-cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo) :: nao(nuloInterdito(Custo)).

update(cuidado(IdCuid, _, nuloInterdito, _, _, _))  :: cuidado(IdCuid, _, nuloInterdito, _, _, _).
update(cuidado(IdCuid, _, _, nuloInterdito, _, _))  :: cuidado(IdCuid, _, _, nuloInterdito, _, _).
update(cuidado(IdCuid, _, _, _, nuloInterdito, _))  :: cuidado(IdCuid, _, _, _, nuloInterdito, _).
update(cuidado(IdCuid, _, _, _, _, nuloInterdito))  :: cuidado(IdCuid, _, _, _, _, nuloInterdito).
update(cuidado(IdCuid, _, _, _, _, _))  :: cuidado(IdCuid, _, _, _, _, _).

%% Excecoes de Cuidado
excecao(cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo)) :- cuidado(IdCuid, ListaDeData, ListaDeIdUt, ListaDeIdPrest, ListaDeDescricao, ListaDeCusto),
                                            si(ou(contem(Data, ListaDeData), nuloNaoImpreciso(ListaDeData)), verdadeiro),
                                            si(ou(contem(IdUt, ListaDeIdUt), nuloNaoImpreciso(ListaDeIdUt)), verdadeiro),
                                            si(ou(contem(IdPrest, ListaDeIdPrest), nuloNaoImpreciso(ListaDePrest)), verdadeiro),
                                            si(ou(contem(Descricao, ListaDeDescricao), nuloNaoImpreciso(ListaDeDescricao)), verdadeiro),
                                            si(ou(contem(Custo, ListaDeCusto), nuloNaoImpreciso(ListaDeCusto)), verdadeiro).

% Manipulacao da Base de Conhecimento----------------------------------------------------------------

%% Inserção de conhecimento positivo no Sistema --------------------------------------
% Adiciona Utente ao sistema
addUtentePos(IdUt, Nome, Idade, Morada) :- evolucao(utente(IdUt, Nome, Idade, Morada)).
% Adiciona Prestador ao sistema
addPrestadorPos(IdPrest, Nome, Especialidade, Instituicao) :- evolucao(prestador(IdPrest, Nome, Especialidade, Instituicao)).
% Adiciona Cuidados ao Sistema
addCuidadoPos(IdCuid, Data, IdUt, IdPrest, Descricao, Custo) :- evolucao(cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo)).

%% Inserção de conhecimento negativo no Sistema --------------------------------------
% Adiciona Utente ao sistema
addUtenteNeg(IdUt, Nome, Idade, Morada) :- evolucao(-utente(IdUt, Nome, Idade, Morada)).
% Adiciona Prestador ao sistema
addPrestadorNeg(IdPrest, Nome, Especialidade, Instituicao) :- evolucao(-prestador(IdPrest, Nome, Especialidade, Instituicao)).
% Adiciona Cuidados ao Sistema
addCuidadoNeg(IdCuid, Data, IdUt, IdPrest, Descricao, Custo) :- evolucao(-cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo)).

% Não se pode adicionar conhecimento negativo que seja verdade.
+(-T) :: nao(T).

% Não se pode adicionar conhecimento negativo repetido, ou seja, todas as variáveis iguais.
+(-utente(IdUt, Nome, Idade, Morada)) :: (findall(IdUt, -utente(IdUt, Nome, Idade, Morada), L),
                                          comprimento(L,1)).

+(-prestador(IdPrest, Nome, Especialidade, Instituicao)) :: (findall(IdPrest, -prestador(IdPrest, Nome, Especialidade, Instituicao), L),
                                          comprimento(L,1)).

+(-cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo)) :: (findall(IdCuid, -cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo), L),
                                          comprimento(L,1)).


%% Alteração de conhecimento positivo no Sistema --------------------------------------
alterUtenteNome(IdUt,Nome):- utente(IdUt,N,I,M), atualizacao(utente(IdUt,N,I,M), utente(IdUt,Nome,I,M)).
alterUtenteIdade(IdUt,Idade):- utente(IdUt,N,I,M), atualizacao(utente(IdUt,N,I,M), utente(IdUt,N,Idade,M)).
alterUtenteMorada(IdUt,Morada):- utente(IdUt,N,I,M), atualizacao(utente(IdUt,N,I,M), utente(IdUt,N,I,Morada)).

alterPrestadorNome(IdPrest,Nome):- prestador(IdPrest, N, E, I),atualizacao(prestador(IdPrest, N, E, I),prestador(IdPrest, Nome, E, I)).
alterPrestadorEspecialidade(IdPrest,Esp):- prestador(IdPrest, N, E, I), atualizacao(prestador(IdPrest, N, E, I),prestador(IdPrest, N, Esp, I)).
alterPrestadorInstituicao(IdPrest,Inst):- prestador(IdPrest, N, E, I), atualizacao(prestador(IdPrest, N, E, I),prestador(IdPrest, N, E, Inst)).

alterCuidadoData(IdCuid,Data) :- cuidado(IdCuid, D, IU, IP, De, C), atualizacao(cuidado(IdCuid, D, IU, IP, De, C),cuidado(IdCuid, Data, IU, IP, De, C)).
alterCuidadoUtente(IdCuid,Ut) :- cuidado(IdCuid, D, IU, IP, De, C), atualizacao(cuidado(IdCuid, D, IU, IP, De, C),cuidado(IdCuid, D, Ut, IP, De, C)).
alterCuidadoPrest(IdCuid,Pret) :- cuidado(IdCuid, D, IU, IP, De, C), atualizacao(cuidado(IdCuid, D, IU, IP, De, C),cuidado(IdCuid, D, IU, Pret, De, C)).
alterCuidadoDesc(IdCuid,Desc) :- cuidado(IdCuid, D, IU, IP, De, C), atualizacao(cuidado(IdCuid, D, IU, IP, De, C),cuidado(IdCuid, D, IU, IP, Desc, C)).
alterCuidadoCust(IdCuid,Custo) :- cuidado(IdCuid, D, IU, IP, De, C), atualizacao(cuidado(IdCuid, D, IU, IP, De, C),cuidado(IdCuid, D, IU, IP, De, Custo)).


%% Remoção de conhecimento positivo no Sistema --------------------------------------
% Remove Utente ao sistema
removeUtentePos(IdUt, Nome, Idade, Morada) :- involucao(utente(IdUt, Nome, Idade, Morada)).
% Remove Prestador ao sistema
removePrestadorPos(IdPrest, Nome, Especialidade, Instituicao) :- involucao(prestador(IdPrest, Nome, Especialidade, Instituicao)).
% Remove Cuidados ao Sistema
removeCuidadoPos(IdCuid, Data, IdUt, IdPrest, Descricao, Custo) :- involucao(cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo)).

%% Remoção de conhecimento negativo no Sistema --------------------------------------
% Remove Utente ao sistema
removeUtenteNeg(IdUt, Nome, Idade, Morada) :- involucao(-utente(IdUt, Nome, Idade, Morada)).
% Remove Prestador ao sistema
removePrestadorNeg(IdPrest, Nome, Especialidade, Instituicao) :- involucao(-prestador(IdPrest, Nome, Especialidade, Instituicao)).
% Remove Cuidados ao Sistema
removeCuidadoNeg(IdCuid, Data, IdUt, IdPrest, Descricao, Custo) :- involucao(-cuidado(IdCuid, Data, IdUt, IdPrest, Descricao, Custo)).


contem(X, X).
contem(X, [X|T]).
% Contem especial para intervalos
contem(X, [(range(L, H))|T]) :- X >= L, X =< H.
contem(X, [_|T]) :- contem(X, T).

% Contém que retorna se é uma lista ou não
contem(X, X, 1).
contem(X, [X|T], 2).
contem(X, [(range(L, H))|T], 2).
contem(X, [_|T], R) :- contem(X, T, R).

makeList(2, [H|T], [H|T]).
makeList(2, Custo, [Custo]).
makeList(_, Custo, Custo).  

%Cálculo da quantidade de gastos/lucros.

gastosTotaisUtente(IdUt, CC, II, IS) :- findall((1,C), cuidado(_, _, IdUt, _, _, C), L), soma(L,CC,II,IS).

lucroTotalInstituicao(Instituicao, CC, II, IS) :- findall((Type,C), (cuidado(_, _, _, IdPrest, _, C), prestador(IdPrest, _, _, X), 
                                                  contem(Instituicao, X, Type)), L), soma(L,CC,II,IS).

lucroTotalEspecialidade(Especialidade, CC, II, IS) :- findall((Type,C), (cuidado(_, _, _, IdPrest, _, C), prestador(IdPrest, _, X, _), 
                                                  contem(Especialidade, X, Type)), L), soma(L,CC,II,IS).

lucroTotalData(Data, CC, II, IS) :- findall((Type,C), (cuidado(_, X, _, _, _, C), contem(Data,X,Type)), L), soma(L,CC,II,IS).


%Funcao auxiliar de somar
% CC -> CustoCerto -- quanto paga de certeza
% II -> IncertezaInferior -- valor minimo que é incerto pagar
% IS -> IncertezaSuperior -- valor máximo que é incerto pagar

soma([], 0, 0, 0).
soma([(_,[H|T1])|T2], Total, IITotal, ISTotal) :- soma(T2, Total, RestoI, RestoS), somaAux([H|T1], AuxI, AuxS), 
                                                                               IITotal is RestoI + AuxI, 
                                                                               ISTotal is RestoS + AuxS. 
soma([(_,H)|T], Total, II, IS) :- H == nuloInterdito, soma(T, Total, II, IS).                                                                                
soma([(1,H)|T], Total, II, IS) :- H \= nuloInterdito, soma(T, Resto, II, IS), Total is H + Resto.
soma([(2,H)|T], Total, TotalI, TotalS) :- H \= nuloInterdito, soma(T, Total, RestoI, RestoS), TotalI is RestoI + H, TotalS is RestoS + H.

somaAux([], 0, 0).
somaAux([(range(X, Y))|T], IITotal, ISTotal) :- somaAux(T, RestoI, RestoS), IITotal is RestoI + X, ISTotal is RestoS + Y.
somaAux([H|T], IITotal, ISTotal) :- somaAux(T, RestoI, RestoS), IITotal is RestoI + H, ISTotal is RestoS + H.

%% Remoção do Sistema --------------------------------
utente(3,[jorge,manuel],[range(12,14)],aveiro).
utente(1, diogo, 32, guimaraes).
utente(2, maria, 12, nulo).
prestador(1, nuloInterdito, cardiologia, hospitalBraga).

test(1):- addUtentePos(2,[dan,mig],[range(12,20)],braga).
test(2):- addPrestadorPos(2,nuloInterdito,[pediatria,obstetricia],hospitalBraga).
test(3):- addCuidadoPos(1,22/10/2000,2,2,sdf,[range(30,50)]), addCuidadoPos(2,22/10/2000,2,2,sdf,20).
test(4):- addCuidadoPos(3,[data(3, 1, 2019), data(3, 1, 2019)], 2, nulo, texto, nuloInterdito).
% test(4):- atualizacao(utente(2,dan,[14],braga), utente(2,dan,20,braga)).
% test(5):- atualizacao(utente(1, daniel, nuloInterdito, nuloInterdito), utente(1, marcoDantas, nuloInterdito, nuloInterdito)).