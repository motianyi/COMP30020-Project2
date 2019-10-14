%  File     : project2.pl
%  Author   : Tianyi Mo
%  Date     : October 2019
%  Purpose  : COMP30020 Declarative Programming Project 2
%  Language : Prolog
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%


%   Puzzle
%   | _ |C1 |C2 |C3 | . .|Cn |
%   |R1 |X11|X12|X13| . .|X1n|
%   |R2 |X21|X22|X23| . .|X2n|
%   |R3 |X31|X32|X33| . .|X3n|
%   |.  |.  |.  |.  | .  |.  |
%   |.  |.  |.  |.  |   .|.  |
%   |Rn |Xn1|Xn2|Xn3|.  .|Xnn|

%   Rule: 
%

% used library
:-ensure_loaded(library(clpfd)).
:-ensure_loaded(library(apply)).


% puzzle_solution/1 take a Puzzle and apply the constrains to the Puzzle

puzzle_solution(Puzzle) :-
    maplist(same_length(Puzzle), Puzzle),
    number_constraint(Puzzle),
    diagonal_constraint(Puzzle),
    heading_constraint(Puzzle),
    no_variable(Puzzle).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% number_constraint/1 hold when the numbers in the Puzzle has no repetition in
% all non-heading cloumns and rows, and all numbers that are not in headings 
%are integers that greater than or equal to 1 and less than or equal to 9.
number_constraint(Puzzle):-
    Puzzle = [_|Rows],
    maplist(row_number_constraint,Rows),
    maplist(no_repeated_number,Rows),
    transpose(Puzzle, TransposePuzzle),
    TransposePuzzle = [_|Cloumns],
    maplist(no_repeated_number,Cloumns).

% row_number_constraint/1 take a row or column of Puzzle and holds when each 
% number in list (except the head) satisfy the size limit
row_number_constraint([_|Row]):- 
    maplist(size_limit,Row).

% no_repeated_number/1 take a row or column of Puzzle and holds when each 
% number in list (except the head) are all distinct(no repetition). It use 
% all_distinct/1 from prolog clpfd library which detect whether all variable 
% in the List are distinct.
no_repeated_number([_|Row]):-
    all_distinct(Row).

% size_limit/1 take a variable X and is true when the vatiable is greater than 
% or equal to 1 and less than or equal to 9. It use clpfd function "in/2"
size_limit(X):- X in 1..9.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% diagonal_constraint/1 hold when the diagnal variables (top left to 
% bottom right) in the Puzzle are equal except heading.
diagonal_constraint(Puzzle) :- 
    matrix_diag(Puzzle, Diag), 
    list_tail_equal(Diag).

%list equal except the first element
list_tail_equal([_|Xs]):- equal(Xs).

equal([X|Xs]):-equal(X,Xs).
equal(_,[]).
equal(X,[Y|Ys]):-equal(X,Ys),X=Y.


% matrix_diag/2 take Matrix and Matrix and List, is true when the list is the 
% top left to bottom right diagonal of the Matrix.
matrix_diag([], []).
matrix_diag(Matrix, Diagnal) :-
    Matrix = [[X|_]|RestRows],
    Diagnal = [X|RestDiagonals],
    maplist(remove_head, RestRows, RestRowsTail),
    matrix_diag(RestRowsTail, RestDiagonals).

% remove_head/2 take two Lists and return when the second list is equal to the 
% first list remove the head element
remove_head([_|Xs], Xs).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% number_constraint/1 hold when the numbers in the Puzzle has no repetition in
% all non-heading cloumns and rows, and all numbers that are not in headings 
%are integers that greater than or equal to 1 and less than or equal to 9.
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

% sum_constraint/1 take a list and is true when the first element is equal
% to the sum of other elements.
sum_constraint([X|Xs]):- sum_list(Xs, 0, X).

% sum_list/3 take a list, a accumulator A and Sum and is true when 
% the list the Sum is equal to the sum of elements in the list.
% The accumulator is for holding partially computed sum and tail recursion.
sum_list([], Sum, Sum).
sum_list([Y|Ys], A, Sum) :-
    A1 #= Y + A,
    sum_list(Ys, A1, Sum).

% product_constraint/1 take a list and is true when the first element is equal
% to the product of other elements.
product_constraint([X|Xs]):- product_list(Xs, 1, X).

% product_list/3 take a list, a accumulator A and Product and is true when 
% the list the Product is equal to the product of elements in the list.
% The accumulator is for holding partially computed product and tail recursion.
product_list([], Product, Product).
product_list([Y|Ys], A, Product) :-
    A1 #= Y * A,
    product_list(Ys, A1, Product).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%Labeling means systematically trying out values for the finite domain variables Vars until all of them are ground.
no_variable([_Headingrow|Rows]) :- maplist(label, Rows).





% sum_constraint([5,2,A,1,B]), [A, B] ins 1..9, label([A, 3, B]). 



