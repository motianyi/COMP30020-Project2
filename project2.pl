:-ensure_loaded(library(clpfd)).
:-ensure_loaded(library(apply)).


puzzle_solution(Puzzle) :-
    maplist(same_length(Puzzle), Puzzle),
    number_constraint(Puzzle),
    diagonal_constraint(Puzzle),
    valid_headings(Puzzle),
    ground_vars(Puzzle).

% get the diagonal of the matrix
matrix_diag([], []).
matrix_diag([[X|_]|RestRows], [X|RestDiagonals]) :-
    maplist(remove_head, RestRows, RestRowsTail),
    matrix_diag(RestRowsTail, RestDiagonals).

%remove the first element of the list
remove_head([_|Xs], Xs).

%The diagonal of matrix satisty the constraint are equal
diagonal_constraint(Matrix) :- matrix_diag(Matrix, Diag), list_tail_equal(Diag).

%list equal except the first element
list_tail_equal([_|Xs]):- equal(Xs).

equal([X|Xs]):-equal(X,Xs).
equal(_,[]).
equal(X,[Y|Ys]):-equal(X,Ys),X=Y.


valid_headings(Puzzle):-
    transpose(Puzzle, CPuzzle),
    Puzzle = [_|Rows],
    CPuzzle = [_|Cloumns],
    maplist(heading_constraint, Rows),
    maplist(heading_constraint, Cloumns).



%The heading of each row need to be either sum of row or product of row
%thus each row satisfy on of these constraints.
heading_constraint([X|Xs]):-sum_constraint([X|Xs]).
heading_constraint([X|Xs]):-product_constraint([X|Xs]).

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



% The numbers greater than 1 and less than 
number_constraint(Puzzle):-
    Puzzle = [_|Rows],
    maplist(row_number_constraint,Rows),
    transpose(Puzzle, CPuzzle),
    CPuzzle = [_|Cloumns],
    maplist(distint_number,Rows),
    maplist(distint_number,Cloumns).

% each number in row need have size limit and also no repetition
row_number_constraint([_|Row]):- 
    maplist(size_limit,Row).

%distinct number in a row or column except the heading
distint_number([_|Row]):-
    all_distinct(Row).


% Set size restriction for elements, element should 1<=x<=9
size_limit(X):- X in 1..9.

%Labeling means systematically trying out values for the finite domain variables Vars until all of them are ground.
ground_vars([_Headingrow|Rows]) :- maplist(label, Rows).





% sum_constraint([5,2,A,1,B]), [A, B] ins 1..9, label([A, 3, B]). 



