%  File       : project2.pl
%  Author     : Tianyi Mo
%  Student ID : 875556
%  Date       : October 2019
%  Purpose    : COMP30020 Declarative Programming Project 2
%  Language   : Prolog
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file implement the puzzle_solution(Puzzle)

% Define the test puzzle solution finder by defining a puzzle_solution/1
% puzzle_solution(Puzzle)
% such that Puzzle is a list of list represent square matrix, 
%
% The strategy used is to decompose the complex problem to 4 simpler
% constraints, square_matrix_constriant, number_constraint, diagonal_constraint
% and heading_constraint. Each of them test specific part of restriction of the
% puzzle.



% used library
:-ensure_loaded(library(clpfd)).
:-ensure_loaded(library(apply)).


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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code Structure
%
% The codes are divided into 5 sections, the first section (SECTION 0) contains 
% puzzle_solution/1, puzzle_solution/1 uses the predicts of other sections.
% SECTION 0 PUZZLE_SOLUTION
% SECTION 1 SQUARE_MAXTIX_CONSTRAINT
% SECTION 2 NUMBER_CONSTRAINT
% SECTION 3 DIAGONAL_CONSTRAINT
% SECTION 4 HEADING_CONSTRAINT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SECTION 0 PUZZLE_SOLUTION
%
% puzzle_solution/1 take a Puzzle and holds when the Puzzle satisfy following 
% 4 constraints: 
% 1.square_matrix_constraint: 
%       Hold when the Puzzle is square.
% 2.number_constraint:        
%       Hold when variables in Puzzle are in correct range and there is no 
%       deplication in any row or column.
% 3.diagonal_constraint:      
%       Hold when the diagonal elements of Puzzle are same.
% 4.heading_constraint:       
%       Hold when the heading of each row and cloumn is equal to sum or product
%       of other variables.
% it also use label/1 in clpfd library that systematically trying out values 
% for the finite domain variables Vars until all of them are ground.

puzzle_solution(Puzzle) :-
    % satisfy all 4 constraints
    square_matrix_constriant(Puzzle),
    number_constraint(Puzzle),
    diagonal_constraint(Puzzle),
    heading_constraint(Puzzle),
    % labelling
    maplist(label, Puzzle).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SECTION 1 SQUARE_MAXTIX_CONSTRAINT: 
%
% square_matrix_constriant/1 hold when the puzzle is a square matrix, it use
% prolog same_length predicate and maplist in apply library to ensure every 
% row in the Puzzle have same number of elements as the number of rows.
square_matrix_constriant(Puzzle):-
    maplist(same_length(Puzzle), Puzzle).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SECTION 2 NUMBER_CONSTRAINT
%
% number_constraint/1 hold when the numbers in the Puzzle has no repetition in
% all non-heading cloumns and rows, and all numbers that are not in headings 
% are integers that greater than or equal to 1 and less than or equal to 9.
% The no_repeated_number is applied for both rows and columns, and the size
% constraint is only applied for rows.
number_constraint(Puzzle):-
    Puzzle = [_|Rows],
    maplist(row_size_constraint,Rows),
    maplist(no_repeated_number,Rows),
    transpose(Puzzle, TransposePuzzle),
    TransposePuzzle = [_|Cloumns],
    maplist(no_repeated_number,Cloumns).

% row_size_constraint/1 take a row or column of Puzzle and holds when each 
% number in list (except the head) satisfy the size limit
row_size_constraint([_|Row]):- 
    maplist(size_limit,Row).

% no_repeated_number/1 take a row or column of Puzzle and holds when each 
% number in list (except the head) are all distinct(no repetition). It use 
% all_distinct/1 from prolog clpfd library which detect whether all variable 
% in the List are distinct.
no_repeated_number([_|Row]):-
    all_distinct(Row).

% size_limit/1 take a variable X and is true when the variable is greater than 
% or equal to 1 and less than or equal to 9. It use clpfd function "in/2"
size_limit(X):- X in 1..9.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SECTION 3 DIAGONAL_CONSTRAINT
%
% diagonal_constraint/1 hold when the diagnal variables (top left to 
% bottom right) in the Puzzle are equal except heading.
diagonal_constraint(Puzzle) :- 
    matrix_diag(Puzzle, Diag), 
    list_tail_equal(Diag).

% list equal except the first element
list_tail_equal([_|Xs]):-
     equal(Xs).

% equal/1 take a list and is true when all elements in the list are equal.
equal([X|Xs]):-
    equal(X,Xs).

% equal/2 take a number X and a list, it is true when all elements in the 
% list are equal to X.
equal(_,[]).
equal(X,[Y|Ys]):-
    equal(X,Ys),X=Y.


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
% SECTION 4 HEADING_CONSTRAINT
%
% heading_constraint/1 hold when the numbers in the Puzzle has no repetition in
% all non-heading cloumns and rows, and all numbers that are not in headings 
% are integers that greater than or equal to 1 and less than or equal to 9.
heading_constraint(Puzzle):-
    transpose(Puzzle, TransposePuzzle),
    Puzzle = [_|Rows],
    TransposePuzzle = [_|Cloumns],
    maplist(list_heading_constraint, Rows),
    maplist(list_heading_constraint, Cloumns).


% list_heading_constraint/1 take a list (row or column of Puzzle), it is true
% when the heading equal to sum of rest or product of rest. It uses the prolog
% disjunction operator ";".
list_heading_constraint([X|Xs]):-
    sum_constraint([X|Xs]);
    product_constraint([X|Xs]).

% sum_constraint/1 take a list and is true when the first element is equal
% to the sum of other elements.
sum_constraint([X|Xs]):- 
    sum_list(Xs, 0, X).

% sum_list/3 take a list, a accumulator A and Sum and is true when 
% the list the Sum is equal to the sum of elements in the list.
% The accumulator is for holding partially computed sum and tail recursion.
sum_list([], Sum, Sum).
sum_list([Y|Ys], A, Sum) :-
    A1 #= Y + A,
    sum_list(Ys, A1, Sum).

% product_constraint/1 take a list and is true when the first element is equal
% to the product of other elements.
product_constraint([X|Xs]):- 
    product_list(Xs, 1, X).

% product_list/3 take a list, a accumulator A and Product and is true when 
% the list the Product is equal to the product of elements in the list.
% The accumulator is for holding partially computed product and tail recursion.
product_list([], Product, Product).
product_list([Y|Ys], A, Product) :-
    A1 #= Y * A,
    product_list(Ys, A1, Product).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%











% sum_constraint([5,2,A,1,B]), [A, B] ins 1..9, label([A, 3, B]). 



