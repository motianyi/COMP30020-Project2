%  File     : project2.pl
%  Author   : Tianyi Mo
%  Date     : October 2019
%  Purpose  : COMP30020 Declarative Programming Project 2
%  Language : Prolog
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Define the test suite by defining a predicate test/4:
%%	test(Goal,Expected,LimitSecs,Weight)
%% such that Goal is a test goal, Expected is a list of all the solutions of Goal
%% specified as a list of instantiations of Goal.  LimitSecs is the time to allow
%% for all solutions of Goal to be found, and Weight is the value of this one test,
%% relative to all the others, expressed as a number.  The number itself is
%% unimportant; only its value relative to other weights matters.  This permits
%% some tests to be given greater than others.



:-ensure_loaded(library(clpfd)).
:-ensure_loaded(library(apply)).


% puzzle_solution/1 

puzzle_solution(Puzzle) :-
    maplist(same_length(Puzzle), Puzzle),
    number_constraint(Puzzle),
    diagonal_constraint(Puzzle),
    heading_constraint(Puzzle),
    no_variable(Puzzle).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The numbers greater than 1 and less than 
number_constraint(Puzzle):-
    Puzzle = [_|Rows],
    maplist(row_number_constraint,Rows),
    maplist(no_repeated_number,Rows),
    transpose(Puzzle, TransposePuzzle),
    TransposePuzzle = [_|Cloumns],
    maplist(no_repeated_number,Cloumns).

% each number in row need have size limit
row_number_constraint([_|Row]):- 
    maplist(size_limit,Row).

%distinct number in a row or column except the heading
no_repeated_number([_|Row]):-
    all_distinct(Row).

% Set size restriction for elements, element should 1<=x<=9
size_limit(X):- X in 1..9.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The diagonal of matrix satisty the constraint are equal
diagonal_constraint(Matrix) :- 
    matrix_diag(Matrix, Diag), 
    list_tail_equal(Diag).

%list equal except the first element
list_tail_equal([_|Xs]):- equal(Xs).

equal([X|Xs]):-equal(X,Xs).
equal(_,[]).
equal(X,[Y|Ys]):-equal(X,Ys),X=Y.


% get the diagonal of the matrix
matrix_diag([], []).
matrix_diag([[X|_]|RestRows], [X|RestDiagonals]) :-
    maplist(remove_head, RestRows, RestRowsTail),
    matrix_diag(RestRowsTail, RestDiagonals).

%remove the first element of the list
remove_head([_|Xs], Xs).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

heading_constraint(Puzzle):-
    transpose(Puzzle, TransposePuzzle),
    Puzzle = [_|Rows],
    TransposePuzzle = [_|Cloumns],
    maplist(list_heading_constraint, Rows),
    maplist(list_heading_constraint, Cloumns).


%The heading of each row need to be either sum of row or product of row
%thus each row satisfy on of these constraints.
list_heading_constraint([X|Xs]):-sum_constraint([X|Xs]).
list_heading_constraint([X|Xs]):-product_constraint([X|Xs]).

sum_constraint([X|Xs]):- sum_row(Xs, 0, X).
sum_row([], X, X).
sum_row([Y|Ys], A, X) :-
    A1 #= Y + A,
    sum_row(Ys, A1, X).

product_constraint([X|Xs]):- product_row(Xs, 1, X).
product_row([], X, X).
product_row([Y|Ys], A, X) :-
    A1 #= Y * A,
    product_row(Ys, A1, X).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%Labeling means systematically trying out values for the finite domain variables Vars until all of them are ground.
no_variable([_Headingrow|Rows]) :- maplist(label, Rows).





% sum_constraint([5,2,A,1,B]), [A, B] ins 1..9, label([A, 3, B]). 



